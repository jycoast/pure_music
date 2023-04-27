import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pure_music/anims/player_anim.dart';
import 'package:pure_music/audio_service/audio_manager.dart';
import 'package:pure_music/audio_service/services/service_locator.dart';
import 'package:pure_music/model/download_model.dart';
import 'package:pure_music/model/favorite_model.dart';
import 'package:pure_music/model/song_model.dart';
import 'package:pure_music/ui/widget/app_bar.dart';
import 'package:pure_music/ui/widget/player_carousel.dart';
import 'package:pure_music/ui/widget/song_list_carousel.dart';

class PlayPage extends StatefulWidget {
  final bool nowPlay;
  SongModel songModel;
  List<Song> songs;
  int index;

  PlayPage({this.nowPlay, this.songs, this.songModel, this.index});

  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> with TickerProviderStateMixin {
  final _audioManager = getIt<AudioManager>();
  AnimationController controllerPlayer;
  Animation<double> animationPlayer;
  final _commonTween = new Tween<double>(begin: 0.0, end: 1.0);
  SongModel songModel;
  MediaItem mediaItem;
  int globalIndex = 0;

  @override
  initState() {
    super.initState();
    controllerPlayer = new AnimationController(
        duration: const Duration(milliseconds: 15000), vsync: this);
    animationPlayer =
        new CurvedAnimation(parent: controllerPlayer, curve: Curves.linear);
    animationPlayer.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controllerPlayer.repeat();
      } else if (status == AnimationStatus.dismissed) {
        controllerPlayer.forward();
      }
    });
    songModel = widget.songModel;
    globalIndex = widget.index;
    if (widget.nowPlay) {
      initMediaItem(songModel, globalIndex);
    }
  }

  void initMediaItem(SongModel songModel, int index) {
    List<MediaItem> mediaItemList = [];
    for (Song song in songModel.songs) {
      MediaItem mediaItem = MediaItem(
        id: song.songid,
        title: song.title,
        artUri: Uri.parse(song.pic),
        artist: song.author
      );
      mediaItemList.add(mediaItem);
    }
    _audioManager.updatePlayQueue(mediaItemList, index);
  }

  @override
  void dispose() {
    controllerPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SongModel songModel = Provider.of(context);
    DownloadModel downloadModel = Provider.of(context);
    FavoriteModel favouriteModel = Provider.of(context);
    if (songModel.isPlaying) {
      controllerPlayer.forward();
    } else {
      controllerPlayer.stop(canceled: false);
    }
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<MediaItem>(
            stream: _audioManager.mediaItemStream(),
            builder: (context, snapshot) {
              final MediaItem mediaItem = snapshot.data;
              return Column(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        !songModel.showList
                            ? Column(
                                children: <Widget>[
                                  AppBarCarousel(),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05),
                                  RotatePlayer(
                                      animation: _commonTween
                                          .animate(controllerPlayer), mediaItem: mediaItem,),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                  Text(
                                    mediaItem?.artist ?? '',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 15.0),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  Text(
                                    mediaItem?.title ?? '',
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.2),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        IconButton(
                                          onPressed: () => songModel
                                              .setShowList(!songModel.showList),
                                          icon: Icon(
                                            Icons.list,
                                            size: 25.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        IconButton(
                                            onPressed: () => {print('comment')},
                                            icon: Icon(
                                              Icons.comment_outlined,
                                              size: 25.0,
                                              color: Colors.grey,
                                            )),
                                        IconButton(
                                          onPressed: () => favouriteModel
                                              .collect(songModel.currentSong),
                                          icon: favouriteModel.isCollect(
                                                      songModel.currentSong) ==
                                                  true
                                              ? Icon(
                                                  Icons.favorite,
                                                  size: 25.0,
                                                  color: Theme.of(context)
                                                      .accentColor,
                                                )
                                              : Icon(
                                                  Icons.favorite_border,
                                                  size: 25.0,
                                                  color: Colors.grey,
                                                ),
                                        ),
                                        IconButton(
                                          onPressed: () => downloadModel
                                              .download(songModel.currentSong),
                                          icon: downloadModel.isDownload(
                                                  songModel.currentSong)
                                              ? Icon(
                                                  Icons.cloud_done,
                                                  size: 25.0,
                                                  color: Theme.of(context)
                                                      .accentColor,
                                                )
                                              : Icon(
                                                  Icons.cloud_download,
                                                  size: 25.0,
                                                  color: Colors.grey,
                                                ),
                                        ),
                                      ]),
                                ],
                              )
                            : SongListCarousel(),
                      ],
                    ),
                  ),
                  PlayerCarousel(
                    songData: songModel,
                    downloadData: downloadModel,
                    nowPlay: widget.nowPlay,
                  ),
                ],
              );
            }),
      ),
    );
  }
}
