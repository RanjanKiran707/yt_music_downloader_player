import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:youtube_riverpod/models/custom_audio_player.dart';
import 'package:youtube_riverpod/models/local_video.dart';
import 'package:youtube_riverpod/providers.dart';

class AudioControls {
  static playSong(LocalVideo localVideo, WidgetRef ref) async {
    final prevState = ref.read(audioProvider);
    if (prevState != null) {
      await prevState.stop();
    }
    ref.read(audioProvider.notifier).state = CustomAudioPlayer(audio: localVideo);
    final nextState = ref.read(audioProvider);
    await nextState!.initPlay();
  }

  static playPlaylist(List<LocalVideo> list, WidgetRef ref, {int index = 0}) async {
    final prevState = ref.read(audioProvider);
    if (prevState != null) {
      await prevState.stop();
    }
    ref.read(audioProvider.notifier).state = CustomAudioPlayer(audioList: list);
    final nextState = ref.read(audioProvider);
    await nextState!.initPlay(index: index);
  }

  static stop(WidgetRef ref) async {
    final curState = ref.read(audioProvider);
    if (curState == null) return;
    await curState.stop();
    ref.read(miniControllerProvider).animateToHeight(state: PanelState.DISMISS);
    ref.read(audioProvider.notifier).state = null;
  }
}
