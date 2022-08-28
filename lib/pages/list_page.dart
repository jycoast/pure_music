/// Created by RongCheng on 2022/3/2.

import 'package:flutter/material.dart';
import 'package:pure_music/model/music_model.dart';
import 'package:pure_music/pages/search_music.dart';
import 'package:pure_music/utils/audio_player.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> with AutomaticKeepAliveClientMixin{

  List<MusicModel> _data = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("播放列表"),),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 60),
              itemCount: _data.length,
              itemBuilder: (ctx,index){
                MusicModel model = _data[index];
                return InkWell(
                  onTap: ()=> AudioPlayerUtil.listPlayerHandle(musicModels: _data,musicModel: model),
                  child: SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        const SizedBox(width: 15,),
                        Image.network(model.thumbnail, width: 40,height: 40,fit: BoxFit.fitWidth,),
                        const SizedBox(width: 10,),
                        Text(model.name,style: const TextStyle(color: Colors.black87,fontSize: 17),)
                      ],
                    ),
                  ));
              },
              separatorBuilder: (ctx,index) => const Divider(height: 0.0,),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: ()=> AudioPlayerUtil.previousMusic(),
                  child: const Icon(Icons.skip_previous_outlined,size: 30,color: Colors.redAccent,),
                ),
                InkWell(
                  onTap: ()=> AudioPlayerUtil.listPlayerHandle(musicModels: _data),
                  child: const SizedBox(
                    height: 50,
                    child: ListAudioButton(),
                  ),
                ),
                InkWell(
                  onTap: ()=> AudioPlayerUtil.nextMusic(),
                  child: const Icon(Icons.skip_next_outlined,size: 30,color: Colors.redAccent),
                ),
              ],
            ),
          ),
        ],
      )
    );
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
    AudioPlayerUtil.statusListener(key: this, listener: (state){
      if(AudioPlayerUtil.isListPlayer == false) return;
      if(mounted){
        setState(() {
          _playing = state == AudioPlayerState.playing;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Icon(_playing ? Icons.pause_circle_outline_outlined :
    Icons.play_circle_outline_outlined,
      size: 30,color: Colors.redAccent,);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    AudioPlayerUtil.removeStatusListener(this);
    super.dispose();
  }
}
