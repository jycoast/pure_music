import 'package:just_audio/just_audio.dart';
import 'package:pure_music/apis/api.dart';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pure_music/services/audio_service.dart';
import 'package:get_it/get_it.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {

  final AudioPlayerHandler audioHandler = GetIt.asNewInstance() as AudioPlayerHandler;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('music player'),
        ),
        bottomNavigationBar: ControlButtons(audioHandler)
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  final bool shuffle;
  final bool miniplayer;
  final List buttons;
  final Color? dominantColor;

  const ControlButtons(this.audioHandler, {
    this.shuffle = false,
    this.miniplayer = false,
    this.buttons = const ['Previous', 'Play/Pause', 'Next'],
    this.dominantColor,
  });

  @override
  Widget build(BuildContext context) {
    // final MediaItem mediaItem = new MediaItem(id: '11', title: '测试');

    // final bool online = mediaItem.extras!['url'].toString().startsWith('http');

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: miniplayer ? 40.0 : 65.0,
            width: miniplayer ? 40.0 : 65.0,
            child: StreamBuilder<PlaybackState>(
              stream: audioHandler.playbackState,
              builder: (context, snapshot) {
                final playbackState = snapshot.data;
                final processingState = playbackState?.processingState;
                final playing = playbackState?.playing ?? true;
                return Stack(
                  children: [
                    if (processingState == AudioProcessingState.loading ||
                        processingState == AudioProcessingState.buffering)
                      Center(
                        child: SizedBox(
                          height: miniplayer ? 40.0 : 65.0,
                          width: miniplayer ? 40.0 : 65.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme
                                  .of(context)
                                  .iconTheme
                                  .color!,
                            ),
                          ),
                        ),
                      ),
                    if (miniplayer)
                      Center(
                        child: playing
                            ? IconButton(
                          tooltip: '暂停',
                          onPressed: audioHandler.pause,
                          icon: const Icon(
                            Icons.pause_rounded,
                          ),
                          color: Theme
                              .of(context)
                              .iconTheme
                              .color,
                        )
                            : IconButton(
                          tooltip: '播放',
                          onPressed: audioHandler.play,
                          icon: const Icon(
                            Icons.play_arrow_rounded,
                          ),
                          color: Theme
                              .of(context)
                              .iconTheme
                              .color,
                        ),
                      )
                    else
                      Center(
                        child: SizedBox(
                          height: 59,
                          width: 59,
                          child: Center(
                            child: playing
                                ? FloatingActionButton(
                              elevation: 10,
                              tooltip: '暂停',
                              backgroundColor: Colors.white,
                              onPressed: audioHandler.pause,
                              child: const Icon(
                                Icons.pause_rounded,
                                size: 40.0,
                                color: Colors.black,
                              ),
                            )
                                : FloatingActionButton(
                              elevation: 10,
                              tooltip: '播放',
                              backgroundColor: Colors.white,
                              onPressed: audioHandler.play,
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 40.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          )
        ]);
  }
}

abstract class AudioPlayerHandler implements AudioHandler {
  Stream<QueueState> get queueState;

  Future<void> moveQueueItem(int currentIndex, int newIndex);

  ValueStream<double> get volume;

  Future<void> setVolume(double volume);

  ValueStream<double> get speed;
}

class QueueState {
  static const QueueState empty =
  QueueState([], 0, [], AudioServiceRepeatMode.none);

  final List<MediaItem> queue;
  final int? queueIndex;
  final List<int>? shuffleIndices;
  final AudioServiceRepeatMode repeatMode;

  const QueueState(this.queue,
      this.queueIndex,
      this.shuffleIndices,
      this.repeatMode,);

  bool get hasPrevious =>
      repeatMode != AudioServiceRepeatMode.none || (queueIndex ?? 0) > 0;

  bool get hasNext =>
      repeatMode != AudioServiceRepeatMode.none ||
          (queueIndex ?? 0) + 1 < queue.length;

  List<int> get indices =>
      shuffleIndices ?? List.generate(queue.length, (i) => i);
}
