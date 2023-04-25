import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:pure_music/model/song_model.dart';
import 'package:http/http.dart';

import 'dart:convert';

Map<String, API> apiMap = {'kw': KMusicAPI(), 'wy': WYMusicAPI()};
final String defaultApiSource = 'kw';

/// 具体的实现
final KMusicAPI api = apiMap[defaultApiSource];

/// 请求外部接口抽象类，后续考虑适配多种音源
abstract class API {
  static fetchSearchResults(String searchQuery) {
    return api.fetchSearchResults(searchQuery);
  }

  static fetchSongSearchResults(String searchQuery, int page,
      {int count = 20}) {
    return api.fetchSongSearchResults(
        searchQuery: searchQuery, page: page, count: count);
  }

  static getMusicList(int i) {
    return api.getMusicList(i);
  }

  static Future<String> getPlayUrl(String mid) {
    return api.getPlayUrl(mid);
  }

  static Future<String> getSongUrl(Song song) {
    return getPlayUrl(song.songid);
  }

  static Future<String> getLyric(Song song) {
    return api.getLyric(song.songid);
  }

  static Future<List<Song>> searchBykeyWord(String key,
      {int pn = 1, int rn = 50}) {
    return api.searchBykeyWord(key, pn: pn, rn: rn);
  }

  static Future<List<Singer>> getArtistInfo(
      {int pn = 1, int rn = 25, int category = 11}) {
    return api.getArtistInfo(pn: pn, rn: rn, category: category);
  }

  static Future<List<RcmPlayList>> getRcmPlayList(
      {int page = 1, int count = 100}) {
    return api.getRcmPlayList(page, count);
  }

  static Future<List<Song>> getPlayListInfo(String id) {
    return api.getPlayListInfo(id);
  }
}

class KMusicAPI implements API {
  Map<String, String> headers = {};
  String baseUrl = 'http://www.kuwo.cn/api';
  String lyricUrl = 'http://m.kuwo.cn';
  String apiStr = '/api.php?_format=json&_marker=0&api_version=4&ctx=web6dot0';
  String reqId = "904fa612-260e-11ed-a6c2-2d5a015b41b4";
  int httpsStatus = 1;
  String type = 'convert_url';

  Map<String, String> endpoints = {
    'searchUrl': '/www/search/searchMusicBykeyWord',
    'playUrl': '/v1/www/music/playUrl',
    'artistInfo': '/www/artist/artistInfo',
    'musicList': '/www/bang/bang/musicList',
    'rcmPlayList': '/www/classify/playlist/getRcmPlayList',
    'lyricUrl': '/newh5/singles/songinfoandlrc',
    'playListInfo': '/www/playlist/playListInfo'
  };

  Future<Response> getResponse(String params) async {
    Uri url = Uri.parse(baseUrl + params);
    headers = {
      'User-Agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36',
      'Referer': 'http://www.kuwo.cn',
      'Cookie':
          'gid=86d551b1-ff26-41d7-86af-8a1c94d1004c; JSESSIONID=15x90blsw700r1q4hawf27km3x; Hm_lvt_cdb524f42f0ce19b169a8071123a4797=1661181745; _ga=GA1.2.23391679.1661181759; _gid=GA1.2.310724863.1661596442; Hm_lpvt_cdb524f42f0ce19b169a8071123a4797=1661597954; kw_token=03DUIQDCKYZY',
      'csrf': '03DUIQDCKYZY'
    };
    return get(url, headers: headers).onError((error, stackTrace) {
      return Response(error.toString(), 404);
    });
  }

  Future<Response> getResponseCustom(String baseUrl, String params) async {
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

  Future<String> getPlayUrl(String mid) async {
    var params =
        '${endpoints['playUrl']}?mid=$mid&type=$type&httpsStatus=$httpsStatus&br=320kmp3';
    print(params);
    final res = await getResponse(params);
    if (res.statusCode == 200) {
      final Map playUrlMap = json.decode(res.body) as Map;
      return playUrlMap['data']['url'];
    }
  }

  Future<String> getLyric(String mid) async {
    var params = '${endpoints['lyricUrl']}?musicId=$mid';
    final res = await getResponseCustom(lyricUrl, params);

    if (res.statusCode == 200) {
      final Map playUrlMap = json.decode(res.body) as Map;
      String lyric = '';
      List lrcList = playUrlMap['data']['lrclist'];
      if (lrcList == null) {
        return lyric;
      }
      for (int i = 0; i < lrcList.length; i++) {
        double lyricTime = double.parse(lrcList[i]['time']);
        Duration duration = Duration(seconds: lyricTime.toInt());
        lyric = lyric +
            '[${formatDurationInMmSsMs(duration)}]' +
            lrcList[i]['lineLyric'].toString() +
            '\n';
      }
      return lyric;
    }
  }

  Future<List> getReco(String pid) async {
    final String params = "${endpoints['getReco']}&pid=$pid";
    final res = await getResponse(params);
    if (res.statusCode == 200) {
      final List getMain = json.decode(res.body) as List;
      return getMain;
    }
    return List.empty();
  }

  Future<List<Song>> searchBykeyWord(String key,
      {int pn = 1, int rn = 30}) async {
    if (key == "") {
      return List.empty();
    }
    final params =
        "${endpoints['searchUrl']}?key=$key&pn=$pn&rn=$rn&httpsStatus=$httpsStatus&reqId=$reqId";
    try {
      final res = await getResponse(params);
      Map<String, dynamic> resMap = json.decode(res.body);
      List<Song> list = [];
      for (Map<String, dynamic> map in resMap['data']['list']) {
        Song model = Song.fromJsonMap(map);
        list.add(model);
      }
      return list;
    } catch (e) {
      log('Error in fetchAlbumSongs: $e');
      return List.empty();
    }
  }

  Future<List<Singer>> getArtistInfo(
      {int pn = 1, int rn = 15, int category = 11}) async {
    List<Singer> singerList = [];
    try {
      final params =
          "${endpoints['artistInfo']}?pn=$pn&rn=$rn&httpsStatus=$httpsStatus&reqId=$reqId";
      final res = await getResponse(params);
      if (res.statusCode == 200) {
        final Map data = json.decode(res.body) as Map;
        for (var artist in data['data']['artistList']) {
          Singer singer = Singer.fromJsonMap(artist);
          singerList.add(singer);
        }
      }
    } catch (e) {
      log('Error in getArtistInfo: $e');
    }
    return singerList;
  }

  Future<List> getMusicList(int bangId, {int pn = 1, int rn = 100}) async {
    final params =
        "${endpoints['musicList']}?bangId=$bangId&pn=$pn&rn=$rn&httpsStatus=$httpsStatus&reqId=$reqId";
    try {
      final res = await getResponse(params);
      if (res.statusCode == 200) {
        final Map playUrlMap = json.decode(res.body) as Map;
        List responseList = playUrlMap['data']['musicList'];
        for (var value in responseList) {
          String url = await getPlayUrl(value['rid'].toString());
          value['url'] = url;
        }
        return formatSongsResponse(responseList, 'song');
      }
      return List.empty();
    } catch (e) {
      log('Error in getMusicList: $e');
      return List.empty();
    }
  }

  Future<Map> fetchSongSearchResults({
    String searchQuery,
    int count = 20,
    int page = 1,
  }) async {
    try {
      final params =
          "${endpoints['searchUrl']}?key=$searchQuery&pn=$page&rn=$count&httpsStatus=$httpsStatus&reqId=$reqId";
      print('请求参数: $params');
      final res = await getResponse(params);
      print(res.body.toString());
      Map<dynamic, dynamic> resMap = json.decode(res.body);
      List responseList = resMap['data']['list'];
      for (var value in responseList) {
        String url = await getPlayUrl(value['rid'].toString());
        print(url);
        value['url'] = url;
      }
      return {
        'songs': await formatSongsResponse(responseList, 'song'),
        'error': '',
      };
    } catch (e) {
      log('Error in fetchSongSearchResults: $e');
      return {
        'songs': List.empty(),
        'error': e,
      };
    }
  }

  Future<List<RcmPlayList>> getRcmPlayList(int page, int count) async {
    List<RcmPlayList> rcmPlayList = [];
    final params =
        "${endpoints['rcmPlayList']}?order=new&pn=$page&rn=$count&httpsStatus=$httpsStatus&reqId=$reqId";
    try {
      if (kDebugMode) {
        print('请求参数: $params');
      }
      final res = await getResponse(params);
      if (kDebugMode) {
        print(res.body.toString());
      }
      Map<dynamic, dynamic> resMap = json.decode(res.body);
      for (var data in resMap['data']['data']) {
        RcmPlayList rcmPlay = RcmPlayList.fromJsonMap(data);
        rcmPlayList.add(rcmPlay);
      }
      return rcmPlayList;
    } catch (e) {
      log('Error in getRcmPlayList: $e');
      return rcmPlayList;
    }
  }

  Future<List<Song>> getPlayListInfo(String key,
      {int pn = 1, int rn = 100}) async {
    if (key == "") {
      return List.empty();
    }
    final params =
        "${endpoints['playListInfo']}?pid=$key&pn=$pn&rn=$rn&httpsStatus=$httpsStatus&reqId=$reqId";
    try {
      final res = await getResponse(params);
      Map<String, dynamic> resMap = json.decode(res.body);
      List<Song> list = [];
      for (Map<String, dynamic> map in resMap['data']['musicList']) {
        Song model = Song.fromJsonMap(map);
        list.add(model);
      }
      return list;
    } catch (e) {
      log('Error in fetchAlbumSongs: $e');
      return List.empty();
    }
  }

  Future<List<Map>> fetchSearchResults(String searchQuery) async {
    final Map<String, List> result = {};
    final Map<int, String> position = {};
    List searchedAlbumList = [];
    List searchedPlaylistList = [];
    List searchedArtistList = [];
    List searchedTopQueryList = [];
    position[0] = 'Songs';
    return [result, position];
  }

  static Future<List> formatSongsResponse(
    List responseList,
    String type,
  ) async {
    final List searchedList = [];
    for (int i = 0; i < responseList.length; i++) {
      Map response;
      switch (type) {
        case 'song':
        case 'album':
        case 'playlist':
          response = await formatSingleSongResponse(responseList[i] as Map);
          break;
        default:
          break;
      }

      if (response.containsKey('Error')) {
        log('Error at index $i inside FormatSongsResponse: ${response["Error"]}');
      } else {
        searchedList.add(response);
      }
    }
    return searchedList;
  }

  static Future<Map> formatSingleSongResponse(Map response) async {
    try {
      final List artistNames = [];
      if (response['more_info']['artistMap']['primary_artists'] == null ||
          response['more_info']['artistMap']['primary_artists'].length == 0) {
        if (response['more_info']['artistMap']['featured_artists'] == null ||
            response['more_info']['artistMap']['featured_artists'].length ==
                0) {
          if (response['more_info']['artistMap']['artists'] == null ||
              response['more_info']['artistMap']['artists'].length == 0) {
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
        'id': response['musicrid'],
        'type': response['type'],
        'album': "",
        'year': response['year'],
        'duration': response['duration'],
        // 'language': response['language'].toString().capitalize(),
        // 'genre': response['language'].toString().capitalize(),
        '320kbps': "",
        'has_lyrics': false,
        'lyrics_snippet': "",
        'release_date': response['releaseDate'],
        'album_id': response['albumid'],
        'subtitle': response['artist'] + '-' + response['album'],
        'title': response['name'],
        'artist': response['artist'],
        'album_artist': response['album'],
        'image': response['pic'],
        'perma_url': response['albumpic'],
        'url': response['url'],
        'name': response['name']
      };
      // Hive.box('cache').put(response['id'].toString(), info);
    } catch (e) {
      // log('Error inside FormatSingleSongResponse: $e');
      return {'Error': e};
    }
  }

  static String formatDurationInMmSsMs(Duration duration) {
    final mm = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final ms = (duration.inMicroseconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss.$ms';
  }
}

class WYMusicAPI implements API {}
