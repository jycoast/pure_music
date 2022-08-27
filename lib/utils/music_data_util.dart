import 'package:pure_music/model/music_model.dart';

class MusicDataUtil{

  static List<MusicModel> getMusicData(){
    List<MusicModel> list = [];
    for(Map<String,dynamic> map in _json){
      MusicModel model = MusicModel.fromMap(map);
      list.add(model);
    }
    return list;
  }

  static final List<Map<String,dynamic>> _json = [
    {
      "id":1,
      "name":"城南花已开",
      "author":"三亩地",
      "thumbnail":"https://p1.music.126.net/i-7ktILRPImJ0NwiH8DABg==/109951162885959979.jpg",
      "url":"https://music.163.com/song/media/outer/url?id=468176711.mp3"
    },
    {
      "id":2,
      "name":"My Soul",
      "author":"July",
      "thumbnail":"https://p1.music.126.net/NFl1s5Hl3E37dCaFIDHfNw==/727876697598920.jpg",
      "url":"https://music.163.com/song/media/outer/url?id=5308028.mp3"
    }
  ];
}