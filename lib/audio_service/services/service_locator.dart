import '../audio_manager.dart';
import 'playlist_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:audio_service/audio_service.dart';
import 'audio_handler.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // services
  getIt.registerLazySingleton<PlaylistRepository>(() => DemoPlaylist());

  // page state
  getIt.registerLazySingleton<AudioManager>(() => AudioManager());

  getIt.registerSingleton<AudioHandler>(await initAudioService());

  getIt<AudioManager>().init();
}