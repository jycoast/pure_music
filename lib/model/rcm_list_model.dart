import 'package:flutter/material.dart';
import 'package:flutter_music_app/model/song_model.dart';
import 'package:flutter_music_app/provider/view_state_list_model.dart';
import 'package:localstorage/localstorage.dart';

import '../config/apis/api.dart';

/// 歌单播放列表
class RcmListModel extends ViewStateListModel<Song> {

  String id;

  RcmListModel({this.id});

  @override
  Future<List<Song>> loadData() async {
    return API.getPlayListInfo(id);
  }
}
