import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:youtube_riverpod/data/audio_controls.dart';
import 'package:youtube_riverpod/main.dart';
import 'package:youtube_riverpod/models/local_video.dart';
import 'package:youtube_riverpod/models/playlist.dart';
import 'package:youtube_riverpod/styles/colors.dart';
import 'package:youtube_riverpod/styles/fonts.dart';

class PlaylistPage extends ConsumerStatefulWidget {
  final CPlaylist playlist;
  const PlaylistPage({Key? key, required this.playlist}) : super(key: key);

  @override
  ConsumerState<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends ConsumerState<PlaylistPage> {
  late List<LocalVideo> list;

  bool reorder = false;

  @override
  void initState() {
    super.initState();
    list = widget.playlist.list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGround,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ValueListenableBuilder(
                    valueListenable: hiveRepo.playListBox.listenable(),
                    builder: (context, val, child) {
                      return Image.network(
                        (CPlaylist.fromJson(val.get(widget.playlist.name))).list.isEmpty
                            ? "https://static-cse.canva.com/blob/951430/1600w-wK95f3XNRaM.jpg"
                            : widget.playlist.list.first.thumbnail,
                        height: context.safePercentHeight * 42,
                        fit: BoxFit.fitHeight,
                        color: Colors.black.withOpacity(0.4),
                        colorBlendMode: BlendMode.dstATop,
                      );
                    },
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Text(
                      widget.playlist.name,
                      style: bigTitle,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: PopupMenuButton(
                      color: darkPurple,
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            child: Row(
                              children: [
                                reorder ? const Icon(Icons.check, color: Colors.white) : const SizedBox.shrink(),
                                5.widthBox,
                                Text("Reorder", style: smallBody),
                              ],
                            ),
                            onTap: () {
                              if (!reorder) {
                                context.showToast(
                                    msg: "You can reorder now by dragging", position: VxToastPosition.top);
                              } else {
                                context.showToast(msg: "Reorder is disabled", position: VxToastPosition.top);
                              }
                              setState(() {
                                reorder = !reorder;
                              });
                            },
                          ),
                        ];
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    right: 30,
                    child: MaterialButton(
                      minWidth: 0,
                      padding: const EdgeInsets.all(10),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {
                        AudioControls.playPlaylist(widget.playlist.list, ref);
                      },
                      color: purple,
                      shape: const CircleBorder(),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: 20.heightBox,
            ),
            ValueListenableBuilder(
                valueListenable: hiveRepo.playListBox.listenable(),
                builder: (context, val, child) {
                  final curPlaylist = CPlaylist.fromJson(val.get(widget.playlist.name)).list;
                  return SliverReorderableList(
                    itemBuilder: (context, index) {
                      final currentValue = curPlaylist[index];
                      return ReorderableDragStartListener(
                        enabled: reorder,
                        key: ValueKey(currentValue.id),
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Slidable(
                            key: ValueKey(currentValue),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  borderRadius: BorderRadius.circular(15),
                                  backgroundColor: Colors.redAccent,
                                  icon: Icons.delete,
                                  label: "Delete",
                                  onPressed: (context) {
                                    hiveRepo.deleteSongFromPlaylist(widget.playlist.name, currentValue);
                                  },
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: darkPurple,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currentValue.name,
                                          maxLines: 1,
                                          style: smallTitle,
                                        ),
                                        5.heightBox,
                                        Text(
                                          currentValue.author,
                                          maxLines: 1,
                                          style: smallBody,
                                        )
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton(
                                    color: purple,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    itemBuilder: (context) {
                                      return hiveRepo.playListKeys.map(
                                        (e) {
                                          return PopupMenuItem(
                                            onTap: () {
                                              hiveRepo.addSongToPlaylist(e, currentValue);
                                            },
                                            value: e,
                                            child: Text(e, style: smallBody),
                                          );
                                        },
                                      ).toList();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                        color: orange,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.playlist_add, color: Colors.white),
                                    ),
                                  ),
                                  15.widthBox,
                                  MaterialButton(
                                    minWidth: 0,
                                    padding: const EdgeInsets.all(5),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    onPressed: () {
                                      AudioControls.playPlaylist(curPlaylist, ref, index: index);
                                    },
                                    color: purple,
                                    shape: const CircleBorder(),
                                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: curPlaylist.length,
                    onReorder: (oldIndex, newIndex) {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }

                      final item = list.removeAt(oldIndex);
                      list.insert(newIndex, item);
                      hiveRepo.changePlaylistOrder(widget.playlist);
                    },
                  );
                }),
          ],
        ),
      ),
    );
  }
}
