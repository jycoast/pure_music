import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:pure_music/apis/api.dart';
import 'package:pure_music/utils/mediaitem_converter.dart';
import 'package:pure_music/pages/player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerHandlerImpl extends BaseAudioHandler
    with QueueHandler, SeekHandler
    implements AudioPlayerHandler {
  int? count;
  Timer? _sleepTimer;
  bool recommend = true;
  bool loadStart = true;
  bool useDown = true;
  AndroidEqualizerParameters? _equalizerParams;

  late AudioPlayer? _player;
  late String preferredQuality;
  late bool resetOnSkip;
  // late String? stationId = '';
  // late List<String> stationNames = [];
  // late String stationType = 'entity';
  // late bool cacheSong;
  final _equalizer = AndroidEqualizer();

  final BehaviorSubject<List<MediaItem>> _recentSubject =
  BehaviorSubject.seeded(<MediaItem>[]);
  final _playlist = ConcatenatingAudioSource(children: []);
  @override
  final BehaviorSubject<double> volume = BehaviorSubject.seeded(1.0);
  @override
  final BehaviorSubject<double> speed = BehaviorSubject.seeded(1.0);
  final _mediaItemExpando = Expando<MediaItem>();

  Stream<List<IndexedAudioSource>> get _effectiveSequence => Rx.combineLatest3<
      List<IndexedAudioSource>?,
      List<int>?,
      bool,
      List<IndexedAudioSource>?>(_player!.sequenceStream,
      _player!.shuffleIndicesStream, _player!.shuffleModeEnabledStream,
          (sequence, shuffleIndices, shuffleModeEnabled) {
        if (sequence == null) return [];
        if (!shuffleModeEnabled) return sequence;
        if (shuffleIndices == null) return null;
        if (shuffleIndices.length != sequence.length) return null;
        return shuffleIndices.map((i) => sequence[i]).toList();
      }).whereType<List<IndexedAudioSource>>();

  int? getQueueIndex(
      int? currentIndex,
      List<int>? shuffleIndices, {
        bool shuffleModeEnabled = false,
      }) {
    final effectiveIndices = _player!.effectiveIndices ?? [];
    final shuffleIndicesInv = List.filled(effectiveIndices.length, 0);
    for (var i = 0; i < effectiveIndices.length; i++) {
      shuffleIndicesInv[effectiveIndices[i]] = i;
    }
    return (shuffleModeEnabled &&
        ((currentIndex ?? 0) < shuffleIndicesInv.length))
        ? shuffleIndicesInv[currentIndex ?? 0]
        : currentIndex;
  }

  AudioPlayerHandlerImpl() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    await startService();

    speed.debounceTime(const Duration(milliseconds: 250)).listen((speed) {
      playbackState.add(playbackState.value.copyWith(speed: speed));
    });

    preferredQuality = '96 kbps';
    resetOnSkip = false;

    recommend = true;
    loadStart = true;

    mediaItem.whereType<MediaItem>().listen((item) {
      if (count != null) {
        count = count! - 1;
        if (count! <= 0) {
          count = null;
          stop();
        }
      }

      if (item.artUri.toString().startsWith('http') &&
          item.genre != 'YouTube') {
        addRecentlyPlayed(item);
        _recentSubject.add([item]);

        if (recommend && item.extras!['autoplay'] as bool) {
          Future.delayed(const Duration(seconds: 1), () async {
            final List<MediaItem> mediaQueue = queue.value;
            final int index = mediaQueue.indexOf(item);
            final int queueLength = mediaQueue.length;
            if (queueLength - index > 2) {
              await Future.delayed(const Duration(seconds: 10), () {});
            }
            if (item == mediaItem.value) {
              final List value = await MusicAPI().getReco(item.id);
              value.shuffle();
              // final List value = await SaavnAPI().getRadioSongs(
              //     stationId: stationId!, count: queueLength - index - 20);

              for (int i = 0; i < value.length; i++) {
                final element = MediaItemConverter.mapToMediaItem(
                  value[i] as Map,
                  addedByAutoplay: true,
                );
                if (!mediaQueue.contains(element)) {
                  addQueueItem(element);
                }
              }
            }
          });
        }
      }
    });

    Rx.combineLatest4<int?, List<MediaItem>, bool, List<int>?, MediaItem?>(
        _player!.currentIndexStream,
        queue,
        _player!.shuffleModeEnabledStream,
        _player!.shuffleIndicesStream,
            (index, queue, shuffleModeEnabled, shuffleIndices) {
          final queueIndex = getQueueIndex(
            index,
            shuffleIndices,
            shuffleModeEnabled: shuffleModeEnabled,
          );
          return (queueIndex != null && queueIndex < queue.length)
              ? queue[queueIndex]
              : null;
        }).whereType<MediaItem>().distinct().listen(mediaItem.add);

    // Propagate all events from the audio player to AudioService clients.
    _player!.playbackEventStream.listen(_broadcastState);

    _player!.shuffleModeEnabledStream
        .listen((enabled) => _broadcastState(_player!.playbackEvent));

    _player!.loopModeStream
        .listen((event) => _broadcastState(_player!.playbackEvent));

    _player!.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        stop();
        _player!.seek(Duration.zero, index: 0);
      }
    });
    // Broadcast the current queue.
    _effectiveSequence
        .map(
          (sequence) =>
          sequence.map((source) => _mediaItemExpando[source]!).toList(),
    )
        .pipe(queue);

    if (loadStart) {
      final List lastQueueList = [];

      // final int lastIndex =
      //     await Hive.box('cache').get('lastIndex', defaultValue: 0) as int;

      // final int lastPos =
      //     await Hive.box('cache').get('lastPos', defaultValue: 0) as int;

      final List<MediaItem> lastQueue = lastQueueList
          .map((e) => MediaItemConverter.mapToMediaItem(e as Map))
          .toList();
      if (lastQueue.isEmpty) {
        await _player!.setAudioSource(_playlist, preload: false);
      } else {
        await _playlist.addAll(_itemsToSources(lastQueue));
        await _player!.setAudioSource(
          _playlist,
          // commented out due to some bug in audio_service which causes app to freeze

          // initialIndex: lastIndex,
          // initialPosition: Duration(seconds: lastPos),
        );
      }
    } else {
      await _player!.setAudioSource(_playlist, preload: false);
    }
    _player?.setUrl('https://le-sycdn.kuwo.cn/e3d6d00cad23543612ccf743776cb367/630998e8/resource/n3/77/97/851025454.mp3');
  }

  AudioSource _itemToSource(MediaItem mediaItem) {
    AudioSource audioSource;
    if (mediaItem.artUri.toString().startsWith('file:')) {
      audioSource =
          AudioSource.uri(Uri.file(mediaItem.extras!['url'].toString()));
    } else {
    // } else {
    //   if (downloadsBox.containsKey(mediaItem.id) && useDown) {
    //     audioSource = AudioSource.uri(
    //       Uri.file(
    //         (downloadsBox.get(mediaItem.id) as Map)['path'].toString(),
    //       ),
    //     );
    //   } else {
        // if (cacheSong) {
        //   _audioSource = LockCachingAudioSource(
        //     Uri.parse(
        //       mediaItem.extras!['url'].toString().replaceAll(
        //             '_96.',
        //             "_${preferredQuality.replaceAll(' kbps', '')}.",
        //           ),
        //     ),
        //   );
        // } else {
        audioSource = AudioSource.uri(
          Uri.parse(
            mediaItem.extras!['url'].toString().replaceAll(
              '_96.',
              "_${preferredQuality.replaceAll(' kbps', '')}.",
            ),
          ),
        );
        // }
      }
    _mediaItemExpando[audioSource] = mediaItem;
    return audioSource;
  }

  List<AudioSource> _itemsToSources(List<MediaItem> mediaItems) {
    preferredQuality ='96 kbps';
    // cacheSong =
    //     Hive.box('settings').get('cacheSong', defaultValue: false) as bool;
    useDown = true;
    return mediaItems.map(_itemToSource).toList();
  }

  @override
  Future<void> onTaskRemoved() async {
    final bool stopForegroundService = true;
    if (stopForegroundService) {
      await stop();
    }
  }

  @override
  Future<List<MediaItem>> getChildren(
      String parentMediaId, [
        Map<String, dynamic>? options,
      ]) async {
    switch (parentMediaId) {
      case AudioService.recentRootId:
        return _recentSubject.value;
      default:
        return queue.value;
    }
  }

  @override
  ValueStream<Map<String, dynamic>> subscribeToChildren(String parentMediaId) {
    switch (parentMediaId) {
      case AudioService.recentRootId:
        final stream = _recentSubject.map((_) => <String, dynamic>{});
        return _recentSubject.hasValue
            ? stream.shareValueSeeded(<String, dynamic>{})
            : stream.shareValue();
      default:
        return Stream.value(queue.value)
            .map((_) => <String, dynamic>{})
            .shareValue();
    }
  }

  Future<void> startService() async {
    final bool withPipeline = false;
    if (withPipeline && Platform.isAndroid) {
      final AudioPipeline pipeline = AudioPipeline(
        androidAudioEffects: [
          _equalizer,
        ],
      );
      _player = AudioPlayer(audioPipeline: pipeline);
    } else {
      _player = AudioPlayer();
    }
  }

  Future<void> addRecentlyPlayed(MediaItem mediaitem) async {
    List recentList = [];

    final Map item = MediaItemConverter.mediaItemToMap(mediaitem);
    recentList.insert(0, item);

    final jsonList = recentList.map((item) => jsonEncode(item)).toList();
    final uniqueJsonList = jsonList.toSet().toList();
    recentList = uniqueJsonList.map((item) => jsonDecode(item)).toList();

    if (recentList.length > 30) {
      recentList = recentList.sublist(0, 30);
    }
  }

  Future<void> addLastQueue(List<MediaItem> queue) async {
    final lastQueue =
    queue.map((item) => MediaItemConverter.mediaItemToMap(item)).toList();
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    await _playlist.add(_itemToSource(mediaItem));
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    await _playlist.addAll(_itemsToSources(mediaItems));
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    await _playlist.insert(index, _itemToSource(mediaItem));
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    await _playlist.clear();
    await _playlist.addAll(_itemsToSources(newQueue));
    addLastQueue(newQueue);
    // stationId = '';
    // stationNames = newQueue.map((e) => e.id).toList();
    // SaavnAPI()
    //     .createRadio(names: stationNames, stationType: stationType)
    //     .then((value) async {
    //   stationId = value;
    //   final List songsList = await SaavnAPI()
    //       .getRadioSongs(stationId: stationId!, count: 20 - newQueue.length);

    //   for (int i = 0; i < songsList.length; i++) {
    //     final element = MediaItemConverter.mapToMediaItem(
    //       songsList[i] as Map,
    //       addedByAutoplay: true,
    //     );
    //     if (!queue.value.contains(element)) {
    //       addQueueItem(element);
    //     }
    //   }
    // });
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    final index = queue.value.indexWhere((item) => item.id == mediaItem.id);
    _mediaItemExpando[_player!.sequence![index]] = mediaItem;
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = queue.value.indexOf(mediaItem);
    await _playlist.removeAt(index);
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    await _playlist.removeAt(index);
  }

  @override
  Future<void> moveQueueItem(int currentIndex, int newIndex) async {
    await _playlist.move(currentIndex, newIndex);
  }

  @override
  Future<void> skipToNext() => _player!.seekToNext();

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _playlist.children.length) return;

    _player!.seek(
      Duration.zero,
      index:
      _player!.shuffleModeEnabled ? _player!.shuffleIndices![index] : index,
    );
  }

  @override
  Future<void> play() async {
    var uri = Uri.parse('https://le-sycdn.kuwo.cn/e3d6d00cad23543612ccf743776cb367/630998e8/resource/n3/77/97/851025454.mp3');
    // _player!.playFromUri( uri);
    print('播放');
     _player!.play();
  }

  @override
  Future<void> pause() async {
    print('暂停键');
    _player!.pause();
    // await Hive.box('cache').put('lastIndex', _player!.currentIndex);
    // await Hive.box('cache').put('lastPos', _player!.position.inSeconds);
  }

  @override
  Future<void> seek(Duration position) => _player!.seek(position);

  @override
  Future<void> stop() async {
    await _player!.stop();
    await playbackState.firstWhere(
          (state) => state.processingState == AudioProcessingState.idle,
    );
    // await Hive.box('cache').put('lastIndex', _player!.currentIndex);
    // await Hive.box('cache').put('lastPos', _player!.position.inSeconds);
  }

  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) {
    if (name == 'sleepTimer') {
      _sleepTimer?.cancel();
      if (extras?['time'] != null &&
          extras!['time'].runtimeType == int &&
          extras['time'] > 0 as bool) {
        _sleepTimer = Timer(Duration(minutes: extras['time'] as int), () {
          stop();
        });
      }
    }
    if (name == 'sleepCounter') {
      if (extras?['count'] != null &&
          extras!['count'].runtimeType == int &&
          extras['count'] > 0 as bool) {
        count = extras['count'] as int;
      }
    }

    if (name == 'setBandGain') {
      final bandIdx = extras!['band'] as int;
      final gain = extras['gain'] as double;
      _equalizerParams!.bands[bandIdx].setGain(gain);
    }

    if (name == 'setEqualizer') {
      _equalizer.setEnabled(extras!['value'] as bool);
    }

    if (name == 'getEqualizerParams') {
      return getEqParms();
    }
    return super.customAction(name, extras);
  }

  Future<Map> getEqParms() async {
    _equalizerParams ??= await _equalizer.parameters;
    final List<AndroidEqualizerBand> bands = _equalizerParams!.bands;
    final List<Map> bandList = bands
        .map(
          (e) => {
        'centerFrequency': e.centerFrequency,
        'gain': e.gain,
        'index': e.index
      },
    )
        .toList();

    return {
      'maxDecibels': _equalizerParams!.maxDecibels,
      'minDecibels': _equalizerParams!.minDecibels,
      'bands': bandList
    };
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode mode) async {
    final enabled = mode == AudioServiceShuffleMode.all;
    if (enabled) {
      await _player!.shuffle();
    }
    playbackState.add(playbackState.value.copyWith(shuffleMode: mode));
    await _player!.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
    await _player!.setLoopMode(LoopMode.values[repeatMode.index]);
  }

  @override
  Future<void> setSpeed(double speed) async {
    this.speed.add(speed);
    await _player!.setSpeed(speed);
  }

  @override
  Future<void> setVolume(double volume) async {
    this.volume.add(volume);
    await _player!.setVolume(volume);
  }

  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    print('click method invoke!');
    switch (button) {
      case MediaButton.media:
        _handleMediaActionPressed();
        break;
      case MediaButton.next:
        await skipToNext();
        break;
      case MediaButton.previous:
        await skipToPrevious();
        break;
    }
  }

  late BehaviorSubject<int> _tappedMediaActionNumber;
  Timer? _timer;

  void _handleMediaActionPressed() {
    if (_timer == null) {
      _tappedMediaActionNumber = BehaviorSubject.seeded(1);
      _timer = Timer(const Duration(milliseconds: 800), () {
        final tappedNumber = _tappedMediaActionNumber.value;
        switch (tappedNumber) {
          case 1:
            if (playbackState.value.playing) {
              pause();
            } else {
              play();
            }
            break;
          case 2:
            skipToNext();
            break;
          case 3:
            skipToPrevious();
            break;
          default:
            break;
        }
        _tappedMediaActionNumber.close();
        _timer!.cancel();
        _timer = null;
      });
    } else {
      final current = _tappedMediaActionNumber.value;
      _tappedMediaActionNumber.add(current + 1);
    }
  }

  /// Broadcasts the current state to all clients.
  void _broadcastState(PlaybackEvent event) {
    final playing = _player!.playing;
    final queueIndex = getQueueIndex(
      event.currentIndex,
      _player!.shuffleIndices,
      shuffleModeEnabled: _player!.shuffleModeEnabled,
    );
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player!.processingState]!,
        playing: playing,
        updatePosition: _player!.position,
        bufferedPosition: _player!.bufferedPosition,
        speed: _player!.speed,
        queueIndex: queueIndex,
      ),
    );
  }

  @override
  // TODO: implement queueState
  Stream<QueueState> get queueState => throw UnimplementedError();
}