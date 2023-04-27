import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/button/gf_button_bar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:pure_music/generated/i18n.dart';
import 'package:pure_music/model/local_view_model.dart';
import 'package:pure_music/model/theme_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:pure_music/ui/widget/song_list.dart';

import 'favorite_page.dart';
import 'music_page.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(S.of(context).tabUser,
                style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                UserListWidget(),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class UserListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SliverList(
        delegate: SliverChildListDelegate([
          GFCard(
            boxFit: BoxFit.cover,
            // image: Image.asset('your asset image'),
            title: GFListTile(
              avatar: GFAvatar(
                // backgroundImage: AssetImage('your asset image'),
              ),
              title: Text('纯享音乐'),
            ),
            content: Text("Some quick example text to build on the card"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MusicPage(),
                      ))
                },
                child: GFCard(
                  boxFit: BoxFit.cover,
                  // image: Image.asset('your asset image'),
                  title: GFListTile(
                    avatar: GFAvatar(
                      // backgroundImage: AssetImage('your asset image'),
                    ),
                    title: Text('下载的'),
                    subTitle: Text('Card Sub Title'),
                  ),
                  content: Text("Some quick example text to build on the card"),
                ),
              ),
              GestureDetector(
                onTap: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FavoritePage(),
                      )),
                },
                child: GFCard(
                  boxFit: BoxFit.cover,
                  // image: Image.asset('your asset image'),
                  title: GFListTile(
                    avatar: GFAvatar(
                      // backgroundImage: AssetImage('your asset image'),
                    ),
                    title: Text('我喜欢'),
                    subTitle: Text('Card Sub Title'),
                  ),
                  content: Text("Some quick example text to build on the card"),
                ),
              ),
              GestureDetector(
                onTap: () => {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => SongList())),
                },
                child: GFCard(
                  boxFit: BoxFit.cover,
                  // image: Image.asset('your asset image'),
                  title: GFListTile(
                    avatar: GFAvatar(
                      // backgroundImage: AssetImage('your asset image'),
                    ),
                    title: Text('播放历史'),
                    subTitle: Text('Card Sub Title'),
                  ),
                  content: Text("Some quick example text to build on the card"),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
