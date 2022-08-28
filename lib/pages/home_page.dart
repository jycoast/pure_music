import 'package:flutter/material.dart';
import 'package:pure_music/pages/detail_page.dart';
import 'package:pure_music/pages/list_page.dart';
import 'package:pure_music/pages/play_list_page.dart';
import 'package:pure_music/utils/audio_player.dart';
import 'package:pure_music/utils/music_data_util.dart';
import 'package:pure_music/widgets/music_item.dart';
import 'package:pure_music/model/music_model.dart';
import 'package:pure_music/pages/search_music.dart';

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
            backgroundColor: Colors.yellow,
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
