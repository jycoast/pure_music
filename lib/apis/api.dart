import 'dart:io';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'dart:convert';

import 'package:pure_music/widgets/music_item.dart';

import '../model/music_model.dart';

class MusicAPI {
  Map<String, String> headers = {};
  String baseUrl = 'http://www.kuwo.cn/api';
  String apiStr = '/api.php?_format=json&_marker=0&api_version=4&ctx=web6dot0';

  Map<String, String> endpoints = {'playUrl': 'mid=webapi.getLaunchData'};

  Future<Response> getResponse(String params) async {
    Uri url = Uri.parse(baseUrl + params);
    headers = {
      'User-Agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36',
      'Referer': 'http://www.kuwo.cn',
      'Cookie':
          'gid=86d551b1-ff26-41d7-86af-8a1c94d1004c; JSESSIONID=15x90blsw700r1q4hawf27km3x; Hm_lvt_cdb524f42f0ce19b169a8071123a4797=1661181745; _ga=GA1.2.23391679.1661181759; _gid=GA1.2.310724863.1661596442; Hm_lpvt_cdb524f42f0ce19b169a8071123a4797=1661597954; kw_token=03DUIQDCKYZY',
      'csrf': '03DUIQDCKYZY'
    };
    return get(url, headers: headers).onError((error, stackTrace) {
      return Response(error.toString(), 404);
    });
  }

  Future<String?> getPlayUrl(String mid) async {
    var type = 'convert_url';
    var httpsStatus = '1';
    var params =
        '/v1/www/music/playUrl?mid=226543302&type=convert_url&httpsStatus=1';
    final res = await getResponse(params);
    if (res.statusCode == 200) {
      final Map playUrlMap = json.decode(res.body) as Map;
      return playUrlMap['data']['url'];
    }
    return null;
  }

  Future<List> getReco(String pid) async {
    final String params = "${endpoints['getReco']}&pid=$pid";
    final res = await getResponse(params);
    if (res.statusCode == 200) {
      final List getMain = json.decode(res.body) as List;
      // return FormatResponse.formatSongsResponse(getMain, 'song');
      return getMain;
    }
    return List.empty();
  }

  Future<List<MusicModel>> search(String key) async {
    String params =
        "/www/search/searchMusicBykeyWord?key=" + key + "pn=1&rn=30&httpsStatus=1&reqId=904fa612-260e-11ed-a6c2-2d5a015b41b4";
    final res = await getResponse(params);
    if (res.statusCode != 200) {
      print('搜索失败: ' + res.body.toString());
      return List.empty();
    }
    Map<String, dynamic> resMap = json.decode(res.body);
    List<MusicModel> list = [];
    for (Map<String, dynamic> map in resMap['data']['list']) {
      map['url'] = await getPlayUrl(map['rid'].toString());
      MusicModel model = MusicModel.fromMap(map);
      list.add(model);
    }
    return list;
  }
}
