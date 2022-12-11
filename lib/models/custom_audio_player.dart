import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_riverpod/models/local_video.dart';

class CustomAudioPlayer {
  late AudioPlayer audioPlayer;
  LocalVideo? audio;
  List<LocalVideo>? audioList;

  CustomAudioPlayer({this.audio, this.audioList}) {
    audioPlayer = AudioPlayer();
  }

  Future<void> initPlay({int index = 0}) async {
    if (audio != null) {
      debugPrint("Path =  ${audio!.path}");
      await audioPlayer.setAudioSource(AudioSource.uri(Uri.file(audio!.path), tag: audio));
    }
    if (audioList != null) {
      ConcatenatingAudioSource audioSource = ConcatenatingAudioSource(
        children: audioList!
            .map(
              (e) => AudioSource.uri(Uri.file(e.path), tag: e),
            )
            .toList(),
      );
      await audioPlayer.setAudioSource(audioSource, initialIndex: index);
    }
    debugPrint("Playing");
    debugPrint(audioPlayer.duration.toString());
    audioPlayer.play();
  }

  Future<void> stop() async {
    await audioPlayer.stop();
  }
}
