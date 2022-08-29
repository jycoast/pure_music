import 'package:flutter/material.dart';
import 'package:pure_music/CustomWidgets/play_list_page.dart';
import 'package:pure_music/CustomWidgets/search_bar.dart';
import 'package:pure_music/utils/audio_player.dart';
import 'package:pure_music/model/music_model.dart';

import 'detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  String searchValue = "";

  @override
  bool get wantKeepAlive => true;

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
            toolbarHeight: 50,
            //将高度定到44，设计稿的高度。为了方便适配，
            backgroundColor: Colors.lightGreen,
            elevation: 0,
            title: SearchBar(hintLabel: '搜索音乐/MV/歌单歌手', )),
        body: PlayListPage()
    );
  }

  void itemCallback(MusicModel model,int type){
    if(type == 0){ // 进入详情
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DetailPage(musicModel: model),
      ));
    }else{  // 点击按钮
      AudioPlayerUtil.playerHandle(model: model);
      if(mounted){
        setState(() {});
      }
    }
  }
}
