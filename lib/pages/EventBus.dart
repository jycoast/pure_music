import 'package:event_bus/event_bus.dart';
import 'package:pure_music/model/music_model.dart';

class CustomEvent {
  List<MusicModel> msg;
  CustomEvent(this.msg);
}
EventBus eventBus = new EventBus();