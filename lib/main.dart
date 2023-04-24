
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pure_music/config/provider_manager.dart';
import 'package:pure_music/config/router_manager.dart' as a;
import 'package:pure_music/config/storage_manager.dart';
import 'package:pure_music/generated/i18n.dart';
import 'package:pure_music/model/local_view_model.dart';
import 'package:pure_music/model/theme_model.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:pure_music/ui/page/splash_page.dart';
import 'package:pure_music/ui/page/tab/tab_navigator.dart';

import 'Utils/audio_service.dart';
import 'anims/page_route_anim.dart';

void main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await StorageManager.init();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await Hive.initFlutter('PureMusic');
  } else {
    await Hive.initFlutter();
  }
  await openHiveBox('settings');
  await openHiveBox('downloads');
  await openHiveBox('Favorite Songs');
  await openHiveBox('cache', limit: true);
  await openHiveBox('recently played');
  // 初始化播放器
  await startService();
  var item = MediaItem(
    id: 'https://other-web-nf01-sycdn.kuwo.cn/f22042fd69438b024e5640f19d103366/6446852f/resource/n3/35/5/1615658295.mp3',
    album: 'Album name',
    title: 'Track title',
    artist: 'Artist name',
    duration: const Duration(milliseconds: 123456),
    artUri: Uri.parse('https://img1.kuwo.cn/star/userpl2015/26/68/1681106398218_566304026_500.jpg'),
  );
  AudioHandler _audioHandler = GetIt.I<AudioHandler>();
  _audioHandler.playMediaItem(item);
  // _audioHandler.playFromSearch(queryString);
   _audioHandler.playFromUri(Uri.parse("https://other-web-nf01-sycdn.kuwo.cn/f22042fd69438b024e5640f19d103366/6446852f/resource/n3/35/5/1615658295.mp3"));
  // _audioHandler.playFromMediaId(id);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MyApp());
  });
}


Future<void> startService() async {
  final AudioHandler audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandlerImpl(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.shadow.blackhole.channel.audio',
      androidNotificationChannelName: 'BlackHole',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'drawable/ic_stat_music_note',
      androidShowNotificationBadge: true,
      // androidStopForegroundOnPause: Hive.box('settings')
      // .get('stopServiceOnPause', defaultValue: true) as bool,
      notificationColor: Colors.grey[900],
    ),
  );
  GetIt.I.registerSingleton<AudioHandler>(audioHandler);
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: providers,
        child: Consumer2<ThemeModel, LocaleModel>(
            builder: (context, themeModel, localeModel, child) {
          return RefreshConfiguration(
            hideFooterWhenNotFull: true, //列表数据不满一页,不触发加载更多
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: themeModel.themeData(),
              darkTheme: themeModel.themeData(platformDarkMode: true),
              locale: localeModel.locale,
              localizationsDelegates: const [
                S.delegate,
                RefreshLocalizations.delegate, //下拉刷新
                GlobalCupertinoLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate
              ],
              routes: {
                '/' : (_) => TabNavigator(),
                '/splash' : (_) => SplashPage(),
              },
              supportedLocales: S.delegate.supportedLocales,
              onGenerateRoute: a.Router.generateRoute,
              initialRoute: a.RouteName.splash,
            ),
          );
        }));
  }
}

/// 打开Hive
Future<void> openHiveBox(String boxName, {bool limit = false}) async {
  final box = await Hive.openBox(boxName).onError((error, stackTrace) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dirPath = dir.path;
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      dbFile = File('$dirPath/PureMusic/$boxName.hive');
      lockFile = File('$dirPath/PureMusic/$boxName.lock');
    }
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox(boxName);
    throw 'Failed to open $boxName Box\nError: $error';
  });
  // clear box if it grows large
  if (limit && box.length > 500) {
    box.clear();
  }
}
