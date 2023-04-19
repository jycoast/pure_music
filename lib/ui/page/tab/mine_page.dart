import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pure_music/generated/i18n.dart';
import 'package:pure_music/model/local_view_model.dart';
import 'package:pure_music/model/theme_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:pure_music/ui/widget/song_list.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(S.of(context).tabUser,
                style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                UserListWidget(),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class UserListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var iconColor = Theme.of(context).accentColor;
    var localModel = Provider.of<LocaleModel>(context);
    return ListTileTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SliverList(
        delegate: SliverChildListDelegate([
          ListTile(
            title: Text(S.of(context).darkMode),
            onTap: () {
              switchDarkMode(context);
            },
            leading: Transform.rotate(
              angle: -pi,
              child: Icon(
                Theme.of(context).brightness == Brightness.light
                    ? Icons.brightness_5
                    : Icons.brightness_2,
                color: iconColor,
              ),
            ),
            trailing: CupertinoSwitch(
                activeColor: Theme.of(context).colorScheme.secondary,
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  switchDarkMode(context);
                }),
          ),
          SettingThemeWidget(),
          ListTile(
            title: Text(S.of(context).settingLanguage),
            onTap: () {
              var model = Provider.of<LocaleModel>(context);
              model.switchLocale();
            },
            leading: Icon(
              Icons.public,
              color: iconColor,
            ),
            trailing: CupertinoSwitch(
                activeColor: Theme.of(context).colorScheme.secondary,
                value: localModel.localeIndex == 0,
                onChanged: (value) {
                  localModel.switchLocale();
                }),
          ),
          SettingTimeWidget(),
          ListTile(
            title: Text(S.of(context).playHistory),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SongList()
                ),
              );
            },
            leading: Icon(
              Icons.history,
              color: iconColor,
            ),
            trailing: Icon(
              Icons.navigate_next_rounded,
              color: iconColor,
            ),
          ),
        ]),
      ),
    );
  }

  void switchDarkMode(BuildContext context) {
    if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
      showToast("检测到系统为暗黑模式,已为你自动切换", position: ToastPosition.bottom);
    } else {
      Provider.of<ThemeModel>(context, listen: false).switchTheme(
          userDarkMode: Theme.of(context).brightness == Brightness.light);
    }
  }
}

class SettingThemeWidget extends StatelessWidget {
  SettingThemeWidget();

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(S.of(context).theme),
      leading: Icon(
        Icons.color_lens,
        color: Theme.of(context).accentColor,
      ),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: <Widget>[
              ...Colors.primaries.map((color) {
                return Material(
                  color: color,
                  child: InkWell(
                    onTap: () {
                      var model = Provider.of<ThemeModel>(context);
                      model.switchTheme(color: color);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                    ),
                  ),
                );
              }).toList(),
              Material(
                child: InkWell(
                  onTap: () {
                    var model = Provider.of<ThemeModel>(context);
                    var brightness = Theme.of(context).brightness;
                    model.switchRandomTheme(brightness: brightness);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).accentColor)),
                    width: 40,
                    height: 40,
                    child: Text(
                      "?",
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class SettingTimeWidget extends StatefulWidget {
  @override
  createState() => SettingTimeState();
}

class SettingTimeState extends State<SettingTimeWidget> {
  List<String> times = ['不开启', '10分钟', '15分钟', '20分钟', '30分钟'];
  Timer _timer = null;
  Timer _countdownTimer = null;
  int _countdownTime = 0;

  static String _durationTransform(int seconds) {
    var d = Duration(seconds: seconds);
    List<String> parts = d.toString().split(':');
    return '${parts[1]}分${parts[2].substring(0, 2)}秒';
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(S.of(context).closeTime +
          (_countdownTime == 0
              ? ''
              : ' (' + _durationTransform(_countdownTime) + '后关闭)')),
      leading: Icon(
        Icons.exit_to_app,
        color: Theme.of(context).accentColor,
      ),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: <Widget>[
              ...times.map((time) {
                return ListTile(
                  title: new Center(
                      child: new Text(
                    time,
                    style: new TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 16.0),
                  )),
                  onTap: () {
                    if (_timer != null && _countdownTimer != null) {
                      _timer.cancel();
                      _countdownTimer.cancel();
                    }
                    if (time == '不开启') {
                      _countdownTime = 0;
                      print('已取消');
                    } else {
                      int intTime =
                          int.parse(time.substring(0, time.indexOf('分')));
                      // TODO showToast('$intTime分钟后将被关闭', position: ToastPosition.bottom);
                      print('$intTime分钟后将被关闭');
                      _timer = Timer(Duration(minutes: intTime), () {
                        print('应用即将关闭：' + DateTime.now().toString());
                        SystemNavigator.pop();
                      });
                      _countdownTime = intTime * 60;
                      // 定时更新当前时间的 _countdownTime 字符串
                      _countdownTimer =
                          Timer.periodic(Duration(seconds: 1), (timer) {
                        setState(() {
                          this._countdownTime = _countdownTime - 1;
                        });
                      });
                    }
                    setState(() {});
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}
