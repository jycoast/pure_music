import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:pure_music/audio_service/notifiers/PlayButtonNotifier.dart';
import 'package:pure_music/audio_service/services/service_locator.dart';
import 'package:pure_music/config/apis/api.dart';
import 'package:pure_music/model/download_model.dart';
import 'package:pure_music/model/song_model.dart';
import '../../audio_service/notifiers/progress_notifier.dart';
import '../../audio_service/notifiers/repeat_button_notifier.dart';
import '../../audio_service/audio_manager.dart';

class PlayerCarousel extends StatefulWidget {
  /// 播放列表
  final SongModel songData;
  final DownloadModel downloadData;

  //是否立即播放
  final bool nowPlay;

  /// 音量
  final double volume;

  final Key key;

  final Color color;

  /// 是否是本地资源
  final bool isLocal;

  PlayerCarousel(
      {@required this.songData,
      @required this.downloadData,
      this.nowPlay,
      this.key,
      this.volume: 1.0,
      this.color: Colors.white,
      this.isLocal: false});

  @override
  State<StatefulWidget> createState() => PlayerCarouselState();
}

class PlayerCarouselState extends State<PlayerCarousel> {

  SongModel _songData;
  bool isPlaying = false;
  num curIndex = 0;

  @override
  void initState() {
    _songData = widget.songData;
    if (widget.nowPlay) {
      playAudio();
    }
    _songData.setPlaying(true);
    isPlaying = true;
    super.initState();
  }

  void playAudio() async {
    AudioManager _audioHandler = getIt<AudioManager>();
    MediaItem mediaItem = _audioHandler.getCurretMedia();
    String lyric = await API.getLyricBySongId(mediaItem.id);
    print('获取歌词: $lyric');
    await _audioHandler.play();
    _songData.currentSong.lrc = lyric;
    // Hive.box('recently played').put(mediaItem., s.toJson());
  }

  @override
  void dispose() {
    // 释放所有资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _controllers(context),
    );
  }

  List<Widget> _controllers(BuildContext context) {
    return [
      Visibility(
        visible: !_songData.showList,
        child: bottomPanel(),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Visibility(
              visible: _songData.showList,
              child: IconButton(
                onPressed: () => _songData.setShowList(!_songData.showList),
                icon: Icon(
                  Icons.list,
                  size: 25.0,
                  color: Colors.grey,
                ),
              ),
            ),
            Visibility(
                visible: _songData.showList, child: PreviousSongButton()),
            Visibility(
              visible: _songData.showList,
              child: ClipOval(
                  child: Container(
                color: Theme.of(context).accentColor.withAlpha(30),
                width: 70.0,
                height: 70.0,
                child: PlayButton(),
              )),
            ),
            Visibility(
              visible: _songData.showList,
              child: NextSongButton(),
            ),
            Visibility(visible: _songData.showList, child: RepeatButton()),
          ],
        ),
      ),
    ];
  }

  Widget bottomPanel() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 35.0),
        child: Column(children: <Widget>[
          AudioProgressBar(),
          AudioControlButtons(),
        ]));
  }
}

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _audioManager = getIt<AudioManager>();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: _audioManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          timeLabelPadding: 2.0,
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: _audioManager.seek,
        );
      },
    );
  }
}

class AudioControlButtons extends StatelessWidget {
  const AudioControlButtons({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RepeatButton(),
          PreviousSongButton(),
          PlayButton(),
          NextSongButton(),
          ShuffleButton(),
        ],
      ),
    );
  }
}

class RepeatButton extends StatelessWidget {
  const RepeatButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<AudioManager>();
    return ValueListenableBuilder<RepeatState>(
      valueListenable: pageManager.repeatButtonNotifier,
      builder: (context, value, child) {
        Icon icon;
        switch (value) {
          case RepeatState.off:
            icon = Icon(Icons.repeat, color: Colors.grey);
            break;
          case RepeatState.repeatSong:
            icon = Icon(Icons.repeat_one);
            break;
          case RepeatState.repeatPlaylist:
            icon = Icon(Icons.repeat);
            break;
        }
        return IconButton(
          icon: icon,
          onPressed: pageManager.repeat,
        );
      },
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<AudioManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: Icon(Icons.skip_previous),
          onPressed: (isFirst) ? null : pageManager.previous,
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _audioManager = getIt<AudioManager>();
    return ValueListenableBuilder<ButtonState>(
      valueListenable: _audioManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: Icon(Icons.play_arrow),
              iconSize: 32.0,
              onPressed: _audioManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: Icon(Icons.pause),
              iconSize: 32.0,
              onPressed: _audioManager.pause,
            );
        }
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<AudioManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: Icon(Icons.skip_next),
          onPressed: (isLast) ? null : pageManager.next,
        );
      },
    );
  }
}

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<AudioManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isShuffleModeEnabledNotifier,
      builder: (context, isEnabled, child) {
        return IconButton(
          icon: (isEnabled)
              ? Icon(Icons.shuffle)
              : Icon(Icons.shuffle, color: Colors.grey),
          onPressed: pageManager.shuffle,
        );
      },
    );
  }
}
