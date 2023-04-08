import 'package:flutter_music_app/config/net/base_api.dart';
import 'package:flutter_music_app/model/song_model.dart';

import '../config/apis/api.dart';

class BaseRepository {
  /// 获取音乐列表
  static Future fetchSongList(String input, int page) async {
    var response = await http.post('/', data: {
      'input': input,
      'type': 'kuwo',
      'page': page,
      'filter': 'name',
    });
    return new KMusicAPI().searchBykeyWord(input, pn: 1);
  }
}
