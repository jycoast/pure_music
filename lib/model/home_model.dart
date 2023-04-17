import 'dart:math';
import 'package:pure_music/config/apis/api.dart';
import 'package:pure_music/model/song_model.dart';
import 'package:pure_music/provider/view_state_refresh_list_model.dart';

class HomeModel extends ViewStateRefreshListModel {
  static const albumValueList = ['酒吧', '怀旧', '女歌手', '经典', '热门', ' 工作', '运动', '人群'];
  static const forYouValueList = ['华语', '流行', '轻音乐', '排行榜', '抖音', '古风', '轻音乐', '解压', '开车'];

  List<RcmPlayList> _albums;
  List<Song> _forYou;
  List<Singer> _songers = [];
  List<RcmPlayList> get albums => _albums;
  List<Song> get forYou => _forYou;
  List<Singer> get singeres => _songers;
  @override
  Future<List<Song>> loadData({int pageNum}) async {
    List<Future> futures = [];
    Random r = new Random();
    int _randomSongForYou = r.nextInt(forYouValueList.length);
    String inputForYou = forYouValueList[_randomSongForYou];
    futures.add(API.getRcmPlayList());
    futures.add(API.searchBykeyWord(inputForYou, pn: pageNum));
    futures.add(API.getArtistInfo());
    var result = await Future.wait(futures);
    _albums = result[0];
    _forYou = result[1];
    _songers = result[2];
    return result[1];
  }
}
