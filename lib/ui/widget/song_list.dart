import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pure_music/config/apis/api.dart';
import 'package:pure_music/model/favorite_model.dart';
import 'package:pure_music/model/song_model.dart';
import 'package:pure_music/provider/provider_widget.dart';
import 'package:pure_music/ui/page/player_page.dart';
import 'package:provider/provider.dart';

import '../../model/rcm_list_model.dart';

/// 播放列表
class SongList extends StatefulWidget {
  @override
  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  List<Song> songList = [];

  @override
  void initState() {
    List recentlyPlayed = Hive.box('recently played').values.toList();
    for (var recent in recentlyPlayed) {
      Song song = Song.fromJsonMap2(recent);
      songList.add(song);
    }
    print('初始化$songList');
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      //解决无限高度问题
      // physics: new NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: songList.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            if (null != songList[index]) {
              SongModel songModel = Provider.of(context, listen: false);
              songModel.setSongs(songList);
              songModel.setCurrentIndex(index);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayPage(
                    nowPlay: true,
                  ),
                ),
              );
            }
          },
          child: _buildSongItem(songList[index]),
        );
      },
    );
  }

  Widget _buildSongItem(Song data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
                width: 50,
                height: 50,
                child: Image(image: CachedNetworkImageProvider(data.pic))),
          ),
          SizedBox(
            width: 20.0,
          ),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    data.title,
                    style: data.url == null
                        ? TextStyle(
                            inherit: false,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE0E0E0),
                          )
                        : TextStyle(
                            inherit: false,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    data.author,
                    style: data.url == null
                        ? TextStyle(
                            inherit: false,
                            fontSize: 10.0,
                            color: Color(0xFFE0E0E0),
                          )
                        : TextStyle(
                            inherit: false,
                            fontSize: 10.0,
                            color: Colors.grey,
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}
