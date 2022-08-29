import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pure_music/apis/api.dart';
import 'package:pure_music/model/music_model.dart';
import 'package:pure_music/utils/audio_player.dart';

import '../widgets/music_item.dart';
import 'EventBus.dart';
import 'detail_page.dart';

class PlayListPage extends StatefulWidget {
  const PlayListPage({Key? key}) : super(key: key);

  @override
  State<PlayListPage> createState() => PlayListPageState();
}

class PlayListPageState extends State<PlayListPage>
    with AutomaticKeepAliveClientMixin {
  late StreamSubscription subscription;

  List<MusicModel> data = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    subscription = eventBus.on<CustomEvent>().listen((event) {
      print('eventBus:' + event.msg.toString());
      setState(() {
        data = event.msg;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: const EdgeInsets.only(bottom: 60),
        itemCount: data.length,
        itemBuilder: (ctx, index) {
          print('index: ' + index.toString());
          if (index == 29) {
            LoadNextPage(index);
          }
          return MusicItem(
            model: data[index],
            callback: (type) {
              itemCallback(data[index], type);
            },
          );
        },
        separatorBuilder: (ctx, index) => const Divider(
              height: 0.0,
            ));
  }

  LoadNextPage(index) async {
    data.addAll(await MusicAPI().searchBykeyWord('周杰伦'));
  }

  void itemCallback(MusicModel model, int type) {
    if (type == 0) {
      // 进入详情
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DetailPage(musicModel: model),
      ));
    } else {
      // 点击按钮
      AudioPlayerUtil.playerHandle(model: model);
      if (mounted) {
        setState(() {});
      }
    }
  }
}

class ListAudioButton extends StatefulWidget {
  const ListAudioButton({Key? key}) : super(key: key);

  @override
  State<ListAudioButton> createState() => _ListAudioButtonState();
}

class _ListAudioButtonState extends State<ListAudioButton> {
  bool _playing = false;

  @override
  void initState() {
    // TODO: implement initState
    // 判断是否正在播放
    _playing = AudioPlayerUtil.state == AudioPlayerState.playing;
    super.initState();

    // 监听播放状态
    AudioPlayerUtil.statusListener(
        key: this,
        listener: (state) {
          if (AudioPlayerUtil.isListPlayer == false) return;
          if (mounted) {
            setState(() {
              _playing = state == AudioPlayerState.playing;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _playing
          ? Icons.pause_circle_outline_outlined
          : Icons.play_circle_outline_outlined,
      size: 30,
      color: Colors.redAccent,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    AudioPlayerUtil.removeStatusListener(this);
    super.dispose();
  }
}
