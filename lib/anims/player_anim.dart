import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:pure_music/model/song_model.dart';
import 'package:pure_music/ui/widget/lyric.dart';
import 'package:provider/provider.dart';

class RotatePlayer extends AnimatedWidget {

  MediaItem mediaItem;

  RotatePlayer({Key key, Animation<double> animation, this.mediaItem})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    SongModel songModel = Provider.of(context);
    return GestureDetector(
      onTap: () {
        print('点击动画');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Lyric(
              normalLyric: songModel.currentSong.lrc,
              imgSrc: songModel.currentSong.pic,
              audioPlayer: songModel.audioPlayer,
            ),
          ),
        );
      },
      child: RotationTransition(
        turns: animation,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.width * 0.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: CachedNetworkImageProvider(mediaItem?.artUri.path ?? songModel.currentSong.pic),
            ),
          ),
        ),
      ),
    );
  }
}
