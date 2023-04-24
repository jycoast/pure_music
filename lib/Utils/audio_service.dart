

AudioPlayerHandlerImpl() {
  _init();
}

Future<void> _init() async {
  // final session = await AudioSession.instance;
  // await session.configure(const AudioSessionConfiguration.music());
  //
  // await startService();
  //
  // speed.debounceTime(const Duration(milliseconds: 250)).listen((speed) {
  //   playbackState.add(playbackState.value.copyWith(speed: speed));
  // });
  //
  // preferredQuality = Hive.box('settings')
  //     .get('streamingQuality', defaultValue: '96 kbps')
  //     .toString();
  // resetOnSkip =
  // Hive.box('settings').get('resetOnSkip', defaultValue: false) as bool;
  // // cacheSong =
  // //     Hive.box('settings').get('cacheSong', defaultValue: false) as bool;
  // recommend =
  // Hive.box('settings').get('autoplay', defaultValue: true) as bool;
  // loadStart =
  // Hive.box('settings').get('loadStart', defaultValue: true) as bool;
  //
  // mediaItem.whereType<MediaItem>().listen((item) {
  //   if (count != null) {
  //     count = count! - 1;
  //     if (count! <= 0) {
  //       count = null;
  //       stop();
  //     }
  //   }
  //
  //   if (item.artUri.toString().startsWith('http') &&
  //       item.genre != 'YouTube') {
  //     addRecentlyPlayed(item);
  //     _recentSubject.add([item]);
  //
  //     if (recommend && item.extras!['autoplay'] as bool) {
  //       Future.delayed(const Duration(seconds: 1), () async {
  //         final List<MediaItem> mediaQueue = queue.value;
  //         final int index = mediaQueue.indexOf(item);
  //         final int queueLength = mediaQueue.length;
  //         if (queueLength - index > 2) {
  //           await Future.delayed(const Duration(seconds: 10), () {});
  //         }
  //         if (item == mediaItem.value) {
  //           final List value = await SaavnAPI().getReco(item.id);
  //           value.shuffle();
  //           // final List value = await SaavnAPI().getRadioSongs(
  //           //     stationId: stationId!, count: queueLength - index - 20);
  //
  //           for (int i = 0; i < value.length; i++) {
  //             final element = MediaItemConverter.mapToMediaItem(
  //               value[i] as Map,
  //               addedByAutoplay: true,
  //             );
  //             if (!mediaQueue.contains(element)) {
  //               addQueueItem(element);
  //             }
  //           }
  //         }
  //       });
  //     }
  //   }
  // });
  //
  // Rx.combineLatest4<int?, List<MediaItem>, bool, List<int>?, MediaItem?>(
  //     _player!.currentIndexStream,
  //     queue,
  //     _player!.shuffleModeEnabledStream,
  //     _player!.shuffleIndicesStream,
  //         (index, queue, shuffleModeEnabled, shuffleIndices) {
  //       final queueIndex = getQueueIndex(
  //         index,
  //         shuffleIndices,
  //         shuffleModeEnabled: shuffleModeEnabled,
  //       );
  //       return (queueIndex != null && queueIndex < queue.length)
  //           ? queue[queueIndex]
  //           : null;
  //     }).whereType<MediaItem>().distinct().listen(mediaItem.add);
  //
  // // Propagate all events from the audio player to AudioService clients.
  // _player!.playbackEventStream.listen(_broadcastState);
  //
  // _player!.shuffleModeEnabledStream
  //     .listen((enabled) => _broadcastState(_player!.playbackEvent));
  //
  // _player!.loopModeStream
  //     .listen((event) => _broadcastState(_player!.playbackEvent));
  //
  // _player!.processingStateStream.listen((state) {
  //   if (state == ProcessingState.completed) {
  //     stop();
  //     _player!.seek(Duration.zero, index: 0);
  //   }
  // });
  // // Broadcast the current queue.
  // _effectiveSequence
  //     .map(
  //       (sequence) =>
  //       sequence.map((source) => _mediaItemExpando[source]!).toList(),
  // )
  //     .pipe(queue);
  //
  // if (loadStart) {
  //   final List lastQueueList = await Hive.box('cache')
  //       .get('lastQueue', defaultValue: [])?.toList() as List;
  //
  //   // final int lastIndex =
  //   //     await Hive.box('cache').get('lastIndex', defaultValue: 0) as int;
  //
  //   // final int lastPos =
  //   //     await Hive.box('cache').get('lastPos', defaultValue: 0) as int;
  //
  //   final List<MediaItem> lastQueue = lastQueueList
  //       .map((e) => MediaItemConverter.mapToMediaItem(e as Map))
  //       .toList();
  //   if (lastQueue.isEmpty) {
  //     await _player!.setAudioSource(_playlist, preload: false);
  //   } else {
  //     await _playlist.addAll(_itemsToSources(lastQueue));
  //     await _player!.setAudioSource(
  //       _playlist,
  //       // commented out due to some bug in audio_service which causes app to freeze
  //
  //       // initialIndex: lastIndex,
  //       // initialPosition: Duration(seconds: lastPos),
  //     );
  //   }
  // } else {
  //   await _player!.setAudioSource(_playlist, preload: false);
  // }
}