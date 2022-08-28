import 'package:pure_music/model/music_model.dart';

class MusicDataUtil{

  static List<MusicModel> getMusicData() {
    List<MusicModel> list = [];
    for(Map<String,dynamic> map in _json){
      MusicModel model = MusicModel.fromMap(map);
      list.add(model);
    }
    return list;
  }

  static final List<Map<String,dynamic>> _json = [
    {
      "rid":1,
      "name":"城南花已开",
      "artist":"三亩地",
      "pic":"https://p1.music.126.net/i-7ktILRPImJ0NwiH8DABg==/109951162885959979.jpg",
      "url":"https://le-sycdn.kuwo.cn/2e2d2d736db02827e9dfe536a431dfb7/630a36d8/resource/n3/77/97/851025454.mp3"
    }
  ];
}