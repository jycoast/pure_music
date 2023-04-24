import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pure_music/audio_service/main.dart';
import 'package:pure_music/audio_service/services/service_locator.dart';
import 'package:pure_music/config/apis/api.dart';
import 'package:pure_music/model/download_model.dart';
import 'package:pure_music/model/song_model.dart';
import '../../audio_service/page_manager.dart';

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

  final audioHandler = getIt<AudioHandler>();


  final audioManager = getIt<PageManager>();

  Duration _duration;
  Duration _position;
  SongModel _songData;
  DownloadModel _downloadData;
  bool isPlaying = false;
  double _slider;
  num curIndex = 0;

  AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _songData = widget.songData;
    _downloadData = widget.downloadData;

    if (widget.nowPlay) {
      play();
    }
  }

  void play() async {
    Song song = _songData.currentSong;
    String url = await API.getPlayUrl(song.songid);
    song.url = url;
    print('播放地址${song}');
    MediaItem mediaItem = toMediaItem(song);
    audioHandler.addQueueItem(mediaItem);
    audioManager.play();
  }

  MediaItem toMediaItem(Song song) {
    return MediaItem(id: song.songid, title: song.title, artUri: Uri.parse(song.pic), extras: {'url': song.url},);
  }

  @override
  void dispose() {
    // 释放所有资源
    // AudioManager.instance.release();
    super.dispose();
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
      audioManager.play();
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
                onPressed: () => audioManager.previous(),
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
                onPressed: () => audioManager.next(),
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
                      audioManager.seek(msec);
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

  Widget bottomPanel() {
    return Column(children: <Widget>[
      AudioProgressBar(),
      AudioControlButtons(),
    ]);
  }
}
