import 'package:pure_music/model/download_model.dart';
import 'package:pure_music/model/favorite_model.dart';
import 'package:pure_music/model/local_view_model.dart';
import 'package:pure_music/model/song_model.dart';
import 'package:pure_music/model/theme_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ...independentServices,
  ...uiConsumableProviders
];

/// 独立的model
List<SingleChildStatelessWidget> independentServices = [
  ChangeNotifierProvider<ThemeModel>(
    create: (context) => ThemeModel(),
  ),
  ChangeNotifierProvider<LocaleModel>(
    create: (context) => LocaleModel(),
  ),
  ChangeNotifierProvider<FavoriteModel>(
    create: (context) => FavoriteModel(),
  ),
  ChangeNotifierProvider<DownloadModel>(
    create: (context) => DownloadModel(),
  ),
  ChangeNotifierProvider<SongModel>(
    create: (context) => SongModel(),
  )
];

List<SingleChildStatelessWidget> uiConsumableProviders = [
//  StreamProvider<User>(
//    builder: (context) => Provider.of<AuthenticationService>(context, listen: false).user,
//  )
];