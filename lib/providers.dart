import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:youtube_riverpod/models/custom_audio_player.dart';

final navIndexProvider = StateProvider<int>((ref) => 0);

final audioProvider = StateProvider<CustomAudioPlayer?>((ref) => null);

final miniControllerProvider = Provider.autoDispose((ref) => MiniplayerController());
