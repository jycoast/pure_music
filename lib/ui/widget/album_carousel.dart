import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pure_music/model/favorite_model.dart';
import 'package:pure_music/model/song_model.dart';
import 'package:pure_music/provider/provider_widget.dart';
import 'package:pure_music/ui/page/player_page.dart';
import 'package:provider/provider.dart';

import '../../model/rcm_list_model.dart';

class AlbumCarousel extends StatefulWidget {
  final String input;

  AlbumCarousel({this.input});

  @override
  _AlbumCarouselState createState() => _AlbumCarouselState();
}

class _AlbumCarouselState extends State<AlbumCarousel> {
  Widget _buildSongItem(Song data, int index) {
    FavoriteModel favoriteModel = Provider.of(context);
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
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE0E0E0),
                          )
                        : TextStyle(
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
                            fontSize: 10.0,
                            color: Color(0xFFE0E0E0),
                          )
                        : TextStyle(
                            fontSize: 10.0,
                            color: Colors.grey,
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]),
          ),
          IconButton(
              onPressed: () => favoriteModel.collect(data),
              icon: data.url == null
                  ? Icon(
                      Icons.favorite_border,
                      color: Color(0xFFE0E0E0),
                      size: 20.0,
                    )
                  : favoriteModel.isCollect(data)
                      ? Icon(
                          Icons.favorite,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 20.0,
                        )
                      : Icon(
                          Icons.favorite_border,
                          size: 20.0,
                        ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<RcmListModel>(
        onModelReady: (model) async {
          await model.initData();
        },
        model: RcmListModel(id: widget.input),
        builder: (context, model, child) {
          return Container(
            child: ListView.builder(
              shrinkWrap: true,
              //解决无限高度问题
              physics: new NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: model.list.length,
              itemBuilder: (BuildContext context, int index) {
                Song data = model.list[index];
                return GestureDetector(
                  onTap: () {
                    if (null != data.url) {
                      SongModel songModel = Provider.of(context, listen: false);
                      songModel.setSongs(model.list);
                      songModel.setCurrentIndex(index);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayPage(
                            nowPlay: true,
                            songModel: songModel,
                            index: index,
                          ),
                        ),
                      );
                    }
                  },
                  child: _buildSongItem(data, index + 1),
                );
              },
            ),
          );
        });
  }
}
