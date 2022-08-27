/// Created by RongCheng on 2022/3/2.

import 'package:flutter/material.dart';
import 'package:pure_music/pages/detail_page.dart';
import 'package:pure_music/utils/audio_player.dart';
import 'package:pure_music/utils/music_data_util.dart';
import 'package:pure_music/widgets/music_item.dart';
import 'package:pure_music/model/music_model.dart';
import 'package:pure_music/pages/search_music.dart';

import 'SAppBarSearch.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _SinglePageState();
}

class _SinglePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  String searchValue = "";

  @override
  bool get wantKeepAlive => true;

  final List<String> entries = <String>['A', 'B', 'C'];
  final List<int> colorCodes = <int>[600, 500, 100];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            titleSpacing: 0,
            //清除title左右padding，默认情况下会有一定的padding距离
            toolbarHeight: 44,
            //将高度定到44，设计稿的高度。为了方便适配，
            backgroundColor: Colors.white,
            elevation: 0,
            title: SearchWidget()),
        body: Column(children: [
          Expanded(child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: entries.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 50,
                color: Colors.amber[colorCodes[index]],
                child: Center(child: Text('Entry ${entries[index]}')),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
          ))
        ]));
  }
}
