import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'dart:convert';
import '../model/music_model.dart';

class KwMusicAPI {
  Map<String, String> headers = {};
  String baseUrl = 'http://www.kuwo.cn/api';
  String apiStr = '/api.php?_format=json&_marker=0&api_version=4&ctx=web6dot0';
  String reqId = "904fa612-260e-11ed-a6c2-2d5a015b41b4";
  int httpsStatus = 1;
  String type = 'convert_url';

  Map<String, String> endpoints = {
    'searchUrl': '/www/search/searchMusicBykeyWord',
    'playUrl': '/v1/www/music/playUrl',
    'homeData': '/www/artist/artistInfo' //http://www.kuwo.cn/api/www/artist/artistInfo?category=11&pn=1&rn=6&httpsStatus=1&reqId=1659e180-278b-11ed-b257-e7c7f69ecd4c
  };

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
    var params =
        '${endpoints['playUrl']}?mid=$mid&type=$type&httpsStatus=$httpsStatus';
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

  Future<List<MusicModel>> searchBykeyWord(String key,
      {int pn = 1, int rn = 30}) async {
    if (key == "") {
      return List.empty();
    }
    final params =
        "${endpoints['searchUrl']}?key=$key&pn=$pn&rn=$rn&httpsStatus=$httpsStatus&reqId=$reqId";
    try {
      final res = await getResponse(params);
      Map<String, dynamic> resMap = json.decode(res.body);
      List<MusicModel> list = [];
      for (Map<String, dynamic> map in resMap['data']['list']) {
        map['url'] = await getPlayUrl(map['rid'].toString());
        MusicModel model = MusicModel.fromMap(map);
        list.add(model);
      }
      return list;
    } catch (e) {
      log('Error in fetchAlbumSongs: $e');
      return List.empty();
    }
  }

  Future<Map> fetchHomePageData() async {
    Map result = {};
    try {
      final res = await getResponse(endpoints['homeData']!);
      if (res.statusCode == 200) {
        final Map data = json.decode(res.body) as Map;
        // result = await FormatResponse.formatHomePageData(data);
      }
    } catch (e) {
      log('Error in fetchHomePageData: $e');
    }
    return result;
  }

  Future<Map> fetchSongSearchResults({
    required String searchQuery,
    int count = 20,
    int page = 1,
  }) async {
    final String params =
        "p=$page&q=$searchQuery&n=$count&${endpoints['getResults']}";
    try {
      final res = await getResponse(params);
      if (res.statusCode == 200) {
        final Map getMain = json.decode(res.body) as Map;
        final List responseList = getMain['results'] as List;
        return {
          'songs': responseList,
          'error': '',
        };
      } else {
        return {
          'songs': List.empty(),
          'error': res.body,
        };
      }
    } catch (e) {
      log('Error in fetchSongSearchResults: $e');
      return {
        'songs': List.empty(),
        'error': e,
      };
    }
  }

  Future<List<Map>> fetchSearchResults(String searchQuery) async {
    final Map<String, List> result = {};
    final Map<int, String> position = {};
    List searchedAlbumList = [];
    List searchedPlaylistList = [];
    List searchedArtistList = [];
    List searchedTopQueryList = [];
    return [result, position];
  }
}
