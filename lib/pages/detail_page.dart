import 'package:flutter/material.dart';
import 'package:pure_music/model/music_model.dart';
import 'dart:ui' as ui show window;
import 'package:pure_music/widgets/audio_button.dart';
import 'package:pure_music/widgets/audio_slider.dart';

import '../utils/audio_player.dart';
import 'list_page.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({Key? key, required this.musicModel}) : super(key: key);
  final MusicModel musicModel;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQueryData.fromWindow(ui.window).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(musicModel.name),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              margin: const EdgeInsets.only(top: 40),
              decoration: BoxDecoration(
                border: Border.all(width: 10, color: Colors.white),
                borderRadius: BorderRadius.circular(size.width * 0.3),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xffdddddd),
                      offset: Offset(0.0, 2.0),
                      blurRadius: 10.0,
                      spreadRadius: 0.0)
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size.width * 0.3),
                child: Image.network(musicModel.thumbnail,
                    width: size.width * 0.6,
                    height: size.width * 0.6,
                    fit: BoxFit.cover),
              ),
            ),
            const SizedBox(
              height: 265,
            ),
            // AudioButton(musicModel: musicModel),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
              child: AudioSlider(
                musicModel: musicModel,
              ),
            ),
            Container(
                alignment: Alignment.bottomCenter,
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black12))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () => AudioPlayerUtil.previousMusic(),
                      child: const Icon(
                        Icons.skip_previous_outlined,
                        size: 30,
                        color: Colors.redAccent,
                      ),
                    ),
                    InkWell(
                      onTap: () =>
                          AudioPlayerUtil.listPlayerHandle(musicModels: List.filled(1, musicModel)),
                      child: const SizedBox(
                        height: 50,
                        child: ListAudioButton(),
                      ),
                    ),
                    InkWell(
                      onTap: () => AudioPlayerUtil.nextMusic(),
                      child: const Icon(Icons.skip_next_outlined,
                          size: 30, color: Colors.redAccent),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
