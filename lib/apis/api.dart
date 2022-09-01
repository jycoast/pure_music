import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:pure_music/utils/extensions.dart';
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
          'songs': await formatSongsResponse(responseList, 'song'),
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

  static Future<List> formatSongsResponse(
      List responseList,
      String type,
      ) async {
    final List searchedList = [];
    for (int i = 0; i < responseList.length; i++) {
      Map? response;
      switch (type) {
        case 'song':
        case 'album':
        case 'playlist':
          response = await formatSingleSongResponse(responseList[i] as Map);
          break;
        default:
          break;
      }

      if (response!.containsKey('Error')) {
        log('Error at index $i inside FormatSongsResponse: ${response["Error"]}');
      } else {
        searchedList.add(response);
      }
    }
    return searchedList;
  }

  static Future<Map> formatSingleSongResponse(Map response) async {
    // Map cachedSong = Hive.box('cache').get(response['id']);
    // if (cachedSong != null) {
    //   return cachedSong;
    // }
    try {
      final List artistNames = [];
      if (response['more_info']?['artistMap']?['primary_artists'] == null ||
          response['more_info']?['artistMap']?['primary_artists'].length == 0) {
        if (response['more_info']?['artistMap']?['featured_artists'] == null ||
            response['more_info']?['artistMap']?['featured_artists'].length ==
                0) {
          if (response['more_info']?['artistMap']?['artists'] == null ||
              response['more_info']?['artistMap']?['artists'].length == 0) {
            artistNames.add('Unknown');
          } else {
            try {
              response['more_info']['artistMap']['artists'][0]['id']
                  .forEach((element) {
                artistNames.add(element['name']);
              });
            } catch (e) {
              response['more_info']['artistMap']['artists'].forEach((element) {
                artistNames.add(element['name']);
              });
            }
          }
        } else {
          response['more_info']['artistMap']['featured_artists']
              .forEach((element) {
            artistNames.add(element['name']);
          });
        }
      } else {
        response['more_info']['artistMap']['primary_artists']
            .forEach((element) {
          artistNames.add(element['name']);
        });
      }

      return {
        'id': response['id'],
        'type': response['type'],
        'album': response['more_info']['album'].toString().unescape(),
        'year': response['year'],
        'duration': response['more_info']['duration'],
        'language': response['language'].toString().capitalize(),
        'genre': response['language'].toString().capitalize(),
        '320kbps': response['more_info']['320kbps'],
        'has_lyrics': response['more_info']['has_lyrics'],
        'lyrics_snippet':
        response['more_info']['lyrics_snippet'].toString().unescape(),
        'release_date': response['more_info']['release_date'],
        'album_id': response['more_info']['album_id'],
        'subtitle': response['subtitle'].toString().unescape(),
        'title': response['title'].toString().unescape(),
        'artist': artistNames.join(', ').unescape(),
        'album_artist': response['more_info'] == null
            ? response['music']
            : response['more_info']['music'],
        'image': response['image']
            .toString()
            .replaceAll('150x150', '500x500')
            .replaceAll('50x50', '500x500')
            .replaceAll('http:', 'https:'),
        'perma_url': response['perma_url'],
        'url': response['more_info']['encrypted_media_url'].toString(),
      };
      // Hive.box('cache').put(response['id'].toString(), info);
    } catch (e) {
      // log('Error inside FormatSingleSongResponse: $e');
      return {'Error': e};
    }
  }
}
