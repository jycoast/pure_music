import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:pure_music/config/apis/api.dart';
import 'package:pure_music/provider/view_state_refresh_list_model.dart';

class SongListModel extends ViewStateRefreshListModel<Song> {
  final String input;

  SongListModel({this.input});

  @override
  Future<List<Song>> loadData({int pageNum}) async {
    return API.searchBykeyWord(input, pn: pageNum);
  }
}

class SongModel with ChangeNotifier {
  String _url;

  String get url => _url;

  setUrl(String url) {
    _url = url;
    notifyListeners();
  }

  AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayer get audioPlayer => _audioPlayer;

  List<Song> _songs;

  /// 循环模式的下标
  int repeatIndex = 0;

  /// 循环模式
  final List<String> repeatModeList = ['All', 'Random', 'One'];

  final icons = [
    const Icon(
      Icons.repeat,
      size: 25.0,
      color: Colors.grey,
    ),
    const Icon(
      Icons.shuffle,
      size: 25.0,
      color: Colors.grey,
    ),
    const Icon(
      Icons.repeat_one,
      size: 25.0,
      color: Colors.grey,
    ),
  ];

  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  setPlaying(bool isPlaying) {
    _isPlaying = isPlaying;
    notifyListeners();
  }

  changeRepeat() {
    if (repeatIndex + 1 >= repeatModeList.length) {
      repeatIndex = 0;
    } else {
      repeatIndex++;
    }
    print('模式改变, $repeatIndex');
    notifyListeners();
  }

  bool _showList = false;

  bool get showList => _showList;

  setShowList(bool showList) {
    _showList = showList;
    notifyListeners();
  }

  int currentSongIndex = 0;

  List<Song> get songs => _songs;

  setSongs(List<Song> songs) {
    _songs = songs;
    notifyListeners();
  }

  addSongs(List<Song> songs) {
    _songs.addAll(songs);
    notifyListeners();
  }

  int get length => _songs.length;

  int get songNumber => currentSongIndex + 1;

  setCurrentIndex(int index) {
    currentSongIndex = index;
    notifyListeners();
  }

  /// 在播放列表界面点击后立刻播放
  bool _playNow = false;

  bool get playNow => _playNow;

  setPlayNow(bool playNow) {
    _playNow = playNow;
    notifyListeners();
  }

  Song get currentSong => _songs[currentSongIndex];

  Song get nextSong {
    if (repeatIndex == 0) {
      if (currentSongIndex < length) {
        currentSongIndex++;
      }
      if (currentSongIndex == length) {
        currentSongIndex = 0;
      }
    } else if (repeatIndex == 1) {
      Random r = new Random();
      currentSongIndex = r.nextInt(_songs.length);
    } else if (repeatIndex == 2) {
      currentSongIndex = currentSongIndex;
    }
    notifyListeners();
    return _songs[currentSongIndex];
  }

  Song get prevSong {
    if (repeatIndex == 0) {
      if (currentSongIndex > 0) {
        currentSongIndex--;
      }
      if (currentSongIndex == 0) {
        currentSongIndex = length - 1;
      }
    } else if (repeatIndex == 1) {
      Random r = new Random();
      currentSongIndex = r.nextInt(_songs.length);
    } else if (repeatIndex == 2) {
      currentSongIndex = currentSongIndex;
    }
    notifyListeners();
    return _songs[currentSongIndex];
  }

  Duration _position;

  Duration get position => _position;

  void setPosition(Duration position) {
    _position = position;
    notifyListeners();
  }

  Duration _duration;

  Duration get duration => _duration;

  void setDuration(Duration duration) {
    _duration = duration;
    notifyListeners();
  }
}

class Song {
  String type;
  String link;
  String songid;
  String title;
  String author;
  String lrc;
  String url;
  String pic;

  Song.fromJsonMap(Map<String, dynamic> map)
      : type = map["type"].toString(),
        link = map["link"].toString(),
        songid = map["rid"].toString(),
        title = map["name"].toString(),
        author = map["artist"].toString(),
        lrc = map["lrc"].toString(),
        url = map["url"].toString(),
        pic = map["pic"].toString();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = type;
    data['link'] = link;
    data['songid'] = songid;
    data['title'] = title;
    data['author'] = author;
    data['lrc'] = lrc;
    data['url'] = url;
    data['pic'] = pic;
    return data;
  }

  MediaItem toMediaItem() {
    return MediaItem(id: songid, title: title, artUri: Uri.parse(pic), extras: {'url': url},);
  }

  /// TODO 优化映射模型
  Song.fromJsonMap2(Map<String, dynamic> map)
      : type = map["type"].toString(),
        link = map["link"].toString(),
        songid = map["songid"].toString(),
        title = map["title"].toString(),
        author = map["author"].toString(),
        lrc = map["lrc"].toString(),
        url = map["url"].toString(),
        pic = map["pic"].toString();

  /// TODO 优化映射模型
  Song.fromJsonMap3(Map<dynamic, dynamic> map)
      : type = map["type"].toString(),
        link = map["link"].toString(),
        songid = map["songid"].toString(),
        title = map["title"].toString(),
        author = map["author"].toString(),
        lrc = map["lrc"].toString(),
        url = map["url"].toString(),
        pic = map["pic"].toString();
}

class Singer {
  String name;
  String pic;

  Singer.fromJsonMap(Map<String, dynamic> map)
      : name = map["name"].toString(),
        pic = map["pic"].toString();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = name;
    data['pic'] = pic;
    return data;
  }
}

class RcmPlayList {
  String name;
  String pic;
  String id;

  RcmPlayList.fromJsonMap(Map<String, dynamic> map)
      : name = map["name"].toString(),
        pic = map["img"].toString(),
        id = map["id"].toString();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = name;
    data['pic'] = pic;
    data['id'] = id;
    return data;
  }
}
