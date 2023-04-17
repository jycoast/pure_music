import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';

class Lyric extends StatefulWidget {
  String imgSrc;

  AudioPlayer audioPlayer;

  String normalLyric = '21312321321';

  @override
  _LyricState createState() => _LyricState();

  Lyric({this.imgSrc, this.normalLyric, this.audioPlayer});
}

class _LyricState extends State<Lyric> with SingleTickerProviderStateMixin {
  double sliderProgress = 111658;
  int playProgress = 111658;
  double max_value = 211658;
  bool isTap = false;
  String normalLyric = "qq";
  bool useEnhancedLrc = false;
  var lyricUI = UINetease();

  @override
  void initState() {
    print(widget.normalLyric);
    print(widget.imgSrc);
    normalLyric = widget.normalLyric;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: buildReaderWidget(),
    );
  }

  var lyricPadding = 60.0;

  Stack buildReaderWidget() {
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
          // selectLineBuilder: (progress, confirm) {
          //   return Row(
          //     children: [
          //       Expanded(
          //         child: Container(
          //           decoration: BoxDecoration(color: Colors.green),
          //           height: 1,
          //           width: double.infinity,
          //         ),
          //       ),
          //       Text(
          //         progress.toString(),
          //         style: TextStyle(color: Colors.green),
          //       )
          //     ],
          //   );
          // },
        )
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
