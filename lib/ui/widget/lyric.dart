import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';

class Lyric extends StatefulWidget {
  String imgSrc;

  AudioPlayer audioPlayer;

  String normalLyric = '';

  @override
  _LyricState createState() => _LyricState();

  Lyric({this.imgSrc, this.normalLyric, this.audioPlayer});
}

class _LyricState extends State<Lyric> with SingleTickerProviderStateMixin {
  int playProgress = 0;
  String normalLyric = "";
  AudioPlayer audioPlayer;

  var lyricUI = UINetease();

  @override
  void initState() {
    print(widget.normalLyric);
    print(widget.imgSrc);
    normalLyric = widget.normalLyric;
    audioPlayer = widget.audioPlayer;
    listenPosition();
    print(playProgress);
    super.initState();
  }

  void listenPosition() {
    if (!mounted) {
      return;
    }
    audioPlayer.onPositionChanged.listen((event) {
      if (mounted) {
        setState(() {
          playProgress = event.inMicroseconds;
        });
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: buildReaderWidget(context),
    );
  }

  var lyricPadding = 60.0;

  Stack buildReaderWidget(BuildContext context) {
    return Stack(
      children: [
        ...buildReaderBackground(),
        LyricsReader(
            padding: EdgeInsets.symmetric(
                horizontal: lyricPadding, vertical: lyricPadding),
            model: LyricsModelBuilder.create()
                .bindLyricToMain(normalLyric)
                .getModel(),
            position: playProgress,
            lyricUi: lyricUI,
            playing: true,
            size: Size(double.infinity, MediaQuery.of(context).size.height),
            emptyBuilder: () => Center(
                  child: Text(
                    "No lyrics",
                    style: lyricUI.getOtherMainTextStyle(),
                  ),
                ),
            onTap: () {
              Navigator.pop(context);
            })
      ],
    );
  }

  List<Widget> buildReaderBackground() {
    return [
      Positioned.fill(
        child: Image.network(
          widget.imgSrc,
          fit: BoxFit.cover,
        ),
      ),
      Positioned.fill(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
      )
    ];
  }

  void refreshLyric() {
    lyricUI = UINetease.clone(lyricUI);
  }
}
