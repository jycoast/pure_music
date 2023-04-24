import 'package:audio_manager/audio_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:pure_music/model/download_model.dart';
import 'package:pure_music/model/song_model.dart';
import 'package:pure_music/config/apis/api.dart';

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
  Duration _duration;
  Duration _position;
  SongModel _songData;
  DownloadModel _downloadData;
  bool isPlaying = false;
  double _slider;
  num curIndex = 0;
  String _error;
  double _sliderVolume;
   PlayMode playMode = AudioManager.instance.playMode;

  AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _songData = widget.songData;
    _downloadData = widget.downloadData;
    setupAudio();
    if (widget.nowPlay) {
      // play(_songData.currentSong);
      AudioManager.instance.playOrPause();
    }
  }

  @override
  void dispose() {
    // 释放所有资源
    // AudioManager.instance.release();
    super.dispose();
  }

  void play(Song s) async {
    String url;
    if (_downloadData.isDownload(s)) {
      url = _downloadData.getDirectoryPath + '/${s.title}-${s.songid}.mp3';
    } else {
      url = await API.getSongUrl(s);
    }
    String lyric = await API.getLyric(s);
    print('获取播放地址: $url 播放地址: ${_songData.url}');
    print('获取歌词: $lyric');
    s.url = url;
    playWithAudioManager(s);
    _songData.setPlaying(true);
    _songData.currentSong.lrc = lyric;
    Hive.box('recently played').put(s.songid.toString(), s.toJson());
  }

  void playWithAudioManager(Song song) {
    AudioManager.instance
        .start(song.url, song.title, desc: song.author, cover: song.pic)
        .then((err) => print(err));
  }

  void pause() async {
    await _audioPlayer.pause();
    setState(() => _songData.setPlaying(false));
  }

  void resume() async {
    await _audioPlayer.resume();
    setState(() => _songData.setPlaying(true));
  }

  String _formatDuration(Duration d) {
    if (d == null) return "--:--";
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = "$minute" + ":" + ((second < 10) ? "0$second" : "$second");
    return format;
  }

  @override
  Widget build(BuildContext context) {
    if (_songData.playNow) {
      AudioManager.instance.playOrPause();
    }
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
              visible: _songData.showList,
              child: IconButton(
                onPressed: () => AudioManager.instance.previous(),
                icon: Icon(
                  //Icons.skip_previous,
                  Icons.fast_rewind,
                  size: 25.0,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).accentColor
                      : Color(0xFF787878),
                ),
              ),
            ),
            Visibility(
              visible: _songData.showList,
              child: ClipOval(
                  child: Container(
                color: Theme.of(context).accentColor.withAlpha(30),
                width: 70.0,
                height: 70.0,
                child: IconButton(
                  onPressed: () {
                    _songData.isPlaying ? pause() : resume();
                  },
                  icon: Icon(
                    _songData.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 30.0,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              )),
            ),
            Visibility(
              visible: _songData.showList,
              child: IconButton(
                onPressed: () => AudioManager.instance.next(),
                icon: Icon(
                  //Icons.skip_next,
                  Icons.fast_forward,
                  size: 25.0,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).accentColor
                      : Color(0xFF787878),
                ),
              ),
            ),
            Visibility(
              visible: _songData.showList,
              child: IconButton(
                onPressed: () => _songData.changeRepeat(),
                icon: _songData.icons[_songData.repeatIndex],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget songProgress(BuildContext context) {
    var style = TextStyle(color: Colors.grey);
    return Row(
      children: <Widget>[
        Text(
          _formatDuration(_position),
          style: style,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbColor: Colors.blueAccent,
                  overlayColor: Colors.blue,
                  thumbShape: RoundSliderThumbShape(
                    disabledThumbRadius: 5,
                    enabledThumbRadius: 5,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  activeTrackColor: Colors.blueAccent,
                  inactiveTrackColor: Colors.grey,
                ),
                child: Slider(
                  value: _slider ?? 0,
                  onChanged: (value) {
                    setState(() {
                      _slider = value;
                    });
                  },
                  onChangeEnd: (value) {
                    if (_duration != null) {
                      Duration msec = Duration(
                          milliseconds:
                              (_duration.inMilliseconds * value).round());
                      AudioManager.instance.seekTo(msec);
                    }
                  },
                )),
          ),
        ),
        Text(
          _formatDuration(_duration),
          style: style,
        ),
      ],
    );
  }

  void setupAudio() async {
    List<AudioInfo> _list = [];

    _songData.songs.forEach((song) async {
      String url = await API.getPlayUrl(song.songid);
      song.url = url;
    });

    _songData.songs.forEach((song) async {
      _list.add(AudioInfo(song.url,
          title: song.title, desc: song.author, coverUrl: song.url));
    });


    AudioManager.instance.audioList = _list;
    AudioManager.instance.intercepter = true;
    AudioManager.instance.play(auto: false);

    AudioManager.instance.onEvents((events, args) {
      print("$events, $args");
      switch (events) {
        case AudioManagerEvents.start:
          print(
              "start load data callback, curIndex is ${AudioManager.instance.curIndex}");
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          _slider = 0;
          AudioInfo audioInfo = args;
          audioInfo.url = 'https://ca-sycdn.kuwo.cn/aaffdb3d9d3a728bd2e0c86052077785/644564bd/resource/n1/27/99/257257225.mp3';
          args = audioInfo;
          AudioManager.instance.updateLrc("audio resource loading....");
          break;
        case AudioManagerEvents.ready:
          print("ready to play");
          _error = null;
          _sliderVolume = AudioManager.instance.volume;
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          // if (mounted) {
          //   setState(() {});
          // }
          // if you need to seek times, must after AudioManagerEvents.ready event invoked
          // AudioManager.instance.seekTo(Duration(seconds: 10));
          break;
        case AudioManagerEvents.seekComplete:
          _position = AudioManager.instance.position;
          _slider = _position.inMilliseconds / _duration.inMilliseconds;
          // if (mounted) {
          //   setState(() {});
          // }
          print("seek event is completed. position is [$args]/ms");
          break;
        case AudioManagerEvents.buffering:
          print("buffering $args");
          break;
        case AudioManagerEvents.playstatus:
          isPlaying = AudioManager.instance.isPlaying;
          // if (mounted) {
          //   setState(() {});
          // }
          break;
        case AudioManagerEvents.timeupdate:
          _position = AudioManager.instance.position;
          _slider = _position.inMilliseconds / _duration.inMilliseconds;
          // if (mounted) {
          //   setState(() {});
          // }
          AudioManager.instance.updateLrc(args["position"].toString());
          break;
        case AudioManagerEvents.error:
          _error = args;
          // if (mounted) {
          //   setState(() {});
          // }
          break;
        case AudioManagerEvents.ended:
          AudioManager.instance.next();
          break;
        case AudioManagerEvents.volumeChange:
          _sliderVolume = AudioManager.instance.volume;
          // if (mounted) {
          //   setState(() {});
          // }
          break;
        default:
          break;
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  Widget bottomPanel() {
    return Column(children: <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: songProgress(context),
      ),
      Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: getPlayModeIcon(playMode),
                color: Colors.grey,
                onPressed: () {
                  playMode = AudioManager.instance.nextMode();
                  setState(() {});
                }),
            IconButton(
                iconSize: 36,
                icon: Icon(
                  Icons.skip_previous,
                  color: Colors.grey,
                ),
                onPressed: () => AudioManager.instance.previous()),
            IconButton(
              onPressed: () async {
                bool playing = await AudioManager.instance.playOrPause();
                print("await -- $playing");
              },
              padding: const EdgeInsets.all(0.0),
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 48.0,
                color: Colors.grey,
              ),
            ),
            IconButton(
                iconSize: 36,
                icon: Icon(
                  Icons.skip_next,
                  color: Colors.grey,
                ),
                onPressed: () => AudioManager.instance.next()),
            IconButton(
                icon: Icon(
                  Icons.stop,
                  color: Colors.grey,
                ),
                onPressed: () => AudioManager.instance.stop()),
          ],
        ),
      ),
    ]);
  }

  Widget getPlayModeIcon(PlayMode playMode) {
    switch (playMode) {
      case PlayMode.sequence:
        return Icon(
          Icons.repeat,
          color: Colors.grey,
        );
      case PlayMode.shuffle:
        return Icon(
          Icons.shuffle,
          color: Colors.grey,
        );
      case PlayMode.single:
        return Icon(
          Icons.repeat_one,
          color: Colors.grey,
        );
    }
    return Container();
  }
}
