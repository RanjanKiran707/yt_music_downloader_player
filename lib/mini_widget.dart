import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:rxdart/rxdart.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:youtube_riverpod/data/audio_controls.dart';

import 'models/local_video.dart';
import 'providers.dart';
import 'styles/colors.dart';
import 'styles/fonts.dart';

class MiniPWidget extends ConsumerWidget {
  const MiniPWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioProv = ref.watch(audioProvider);
    final miniController = ref.watch(miniControllerProvider);
    if (audioProv == null) return const SizedBox.shrink();
    return Miniplayer(
      controller: miniController,
      minHeight: 70,
      maxHeight: context.screenHeight,
      backgroundColor: darkPurple,
      builder: (height, percentage) {
        if (height < 100) {
          return Container(
            color: darkPurple,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StreamBuilder<SequenceState?>(
                        stream: audioProv.audioPlayer.sequenceStateStream,
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator());
                          }
                          return Row(
                            children: [
                              Image.network(
                                (snapshot.data!.currentSource!.tag
                                        as LocalVideo)
                                    .thumbnail,
                                height: 65,
                                width: context.screenWidth * 0.3,
                                fit: BoxFit.cover,
                              ),
                              4.widthBox,
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (snapshot.data!.currentSource!.tag
                                              as LocalVideo)
                                          .name,
                                      maxLines: 2,
                                      style: smallTitle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      (snapshot.data!.currentSource!.tag
                                              as LocalVideo)
                                          .author,
                                      maxLines: 1,
                                      style: smallBody,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    StreamBuilder<PlayerState>(
                      initialData: PlayerState(false, ProcessingState.idle),
                      stream: audioProv.audioPlayer.playerStateStream,
                      builder: (context, snapshot) {
                        final data = snapshot.data!;
                        if (data.processingState == ProcessingState.idle ||
                            data.processingState == ProcessingState.loading) {
                          return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator());
                        }
                        if (data.processingState == ProcessingState.completed) {
                          return IconButton(
                            onPressed: () async {
                              await audioProv.audioPlayer.seek(Duration.zero);
                              audioProv.audioPlayer.play();
                            },
                            icon: const Icon(
                              Icons.replay,
                              color: Colors.white,
                            ),
                          );
                        }
                        if (data.playing) {
                          return IconButton(
                            onPressed: () async {
                              await audioProv.audioPlayer.pause();
                            },
                            icon: const Icon(
                              Icons.pause,
                              color: Colors.white,
                            ),
                          );
                        }
                        if (!data.playing) {
                          return IconButton(
                            onPressed: () async {
                              await audioProv.audioPlayer.play();
                            },
                            icon: const Icon(Icons.play_arrow_rounded,
                                color: Colors.white),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    IconButton(
                      onPressed: () {
                        AudioControls.stop(ref);
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                    )
                  ],
                ),
                const Spacer(),
                StreamBuilder<ProgressData>(
                  stream: Rx.combineLatest2(
                    audioProv.audioPlayer.positionStream,
                    audioProv.audioPlayer.durationStream,
                    (a, b) {
                      return ProgressData(a, b ?? Duration.zero);
                    },
                  ),
                  initialData: ProgressData(Duration.zero, Duration.zero),
                  builder: (context, snapshot) {
                    return ProgressBar(
                      onSeek: (duration) {
                        audioProv.audioPlayer.seek(duration);
                      },
                      barCapShape: BarCapShape.square,
                      timeLabelLocation: TimeLabelLocation.none,
                      progress: snapshot.data!.position,
                      total: snapshot.data!.duration,
                      thumbRadius: 2.5,
                      barHeight: 5,
                    );
                  },
                ),
              ],
            ),
          );
        }
        return Container(
          color: backGround,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            ref
                                .read(miniControllerProvider)
                                .animateToHeight(state: PanelState.MIN);
                          },
                          icon: const Icon(Icons.arrow_back_outlined,
                              color: Colors.white),
                        ),
                        20.widthBox,
                        Text("Playing Now", style: mediumTitle),
                      ],
                    ),
                    10.heightBox,
                    StreamBuilder<SequenceState?>(
                      stream: audioProv.audioPlayer.sequenceStateStream,
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {
                          return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator());
                        }
                        final data =
                            snapshot.data!.currentSource!.tag as LocalVideo;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(45),
                              child: Image.network(
                                data.thumbnail,
                                height: context.safePercentHeight * 45,
                                width: context.screenWidth,
                                fit: BoxFit.cover,
                              ),
                            ),
                            15.heightBox,
                            Text(data.name,
                                style: mediumTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            10.heightBox,
                            Text(data.author, style: smallTitle),
                          ],
                        );
                      },
                    ),
                    20.heightBox,
                    StreamBuilder<ProgressData>(
                      stream: Rx.combineLatest2(
                        audioProv.audioPlayer.positionStream,
                        audioProv.audioPlayer.durationStream,
                        (a, b) {
                          return ProgressData(a, b ?? Duration.zero);
                        },
                      ),
                      initialData: ProgressData(Duration.zero, Duration.zero),
                      builder: (context, snapshot) {
                        return ProgressBar(
                          baseBarColor: const Color(0xFF385682),
                          progressBarColor: const Color(0xFF5297FF),
                          onSeek: (duration) {
                            audioProv.audioPlayer.seek(duration);
                          },
                          barCapShape: BarCapShape.round,
                          timeLabelLocation: TimeLabelLocation.below,
                          timeLabelPadding: 10,
                          timeLabelTextStyle:
                              smallTitle.copyWith(color: Colors.white54),
                          progress: snapshot.data!.position,
                          total: snapshot.data!.duration,
                          thumbRadius: 3.5,
                          barHeight: 5,
                        );
                      },
                    ),
                    10.heightBox,
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            audioProv.audioPlayer.shuffle();
                          },
                          icon: const Icon(Icons.shuffle, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {
                            audioProv.audioPlayer.seekToPrevious();
                          },
                          icon: const Icon(Icons.skip_previous_outlined,
                              color: Colors.white),
                        ),
                        MaterialButton(
                          minWidth: 0,
                          padding: const EdgeInsets.all(15),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onPressed: () async {
                            final data = audioProv.audioPlayer.playerState;
                            if (data.processingState ==
                                ProcessingState.completed) {
                              await audioProv.audioPlayer.seek(Duration.zero);
                              audioProv.audioPlayer.play();
                              return;
                            }
                            if (data.playing) {
                              await audioProv.audioPlayer.pause();
                            } else {
                              await audioProv.audioPlayer.play();
                            }
                          },
                          color: purple,
                          shape: const CircleBorder(),
                          child: StreamBuilder<PlayerState>(
                            initialData:
                                PlayerState(false, ProcessingState.idle),
                            stream: audioProv.audioPlayer.playerStateStream,
                            builder: (context, snapshot) {
                              final data = snapshot.data!;
                              if (data.processingState ==
                                      ProcessingState.idle ||
                                  data.processingState ==
                                      ProcessingState.loading) {
                                return const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator());
                              }
                              if (data.processingState ==
                                  ProcessingState.completed) {
                                return const Icon(
                                  Icons.replay,
                                  color: Colors.white,
                                  size: 40,
                                );
                              }
                              if (data.playing) {
                                return const Icon(
                                  Icons.pause,
                                  color: Colors.white,
                                  size: 40,
                                );
                              }
                              if (!data.playing) {
                                return const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 40,
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            audioProv.audioPlayer.seekToNext();
                          },
                          icon: const Icon(Icons.skip_next_outlined,
                              color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {
                            final data = audioProv.audioPlayer.loopMode;
                            switch (data) {
                              case LoopMode.one:
                                audioProv.audioPlayer.setLoopMode(LoopMode.all);
                                break;
                              case LoopMode.off:
                                audioProv.audioPlayer.setLoopMode(LoopMode.one);
                                break;
                              default:
                                audioProv.audioPlayer.setLoopMode(LoopMode.off);
                            }
                          },
                          icon: StreamBuilder<LoopMode>(
                            initialData: LoopMode.off,
                            stream: audioProv.audioPlayer.loopModeStream,
                            builder: (context, snapshot) {
                              if (snapshot.data == LoopMode.off) {
                                return const Icon(Icons.loop,
                                    color: Colors.white);
                              }
                              if (snapshot.data == LoopMode.one) {
                                return Badge(
                                  badgeContent: Text("1", style: smallBody),
                                  child: const Icon(Icons.loop,
                                      color: Colors.white),
                                );
                              }
                              return Badge(
                                badgeContent: Text("all", style: smallBody),
                                child:
                                    const Icon(Icons.loop, color: Colors.white),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProgressData {
  final Duration position;
  final Duration duration;

  ProgressData(this.position, this.duration);
}
