import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_riverpod/data/audio_controls.dart';
import 'package:youtube_riverpod/main.dart';
import 'package:youtube_riverpod/models/local_video.dart';
import 'package:youtube_riverpod/models/playlist.dart';
import 'package:youtube_riverpod/playlist_page.dart';
import 'package:youtube_riverpod/styles/colors.dart';
import 'package:youtube_riverpod/styles/fonts.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  showAddPlaylist(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: darkPurple,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Enter Playist name : ", style: smallTitle),
                TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(),
                  style: smallBody,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    if (ctrl.text == "") return;
                    hiveRepo.addPlaylist(CPlaylist(name: ctrl.text, list: []));
                    Navigator.of(context).pop();
                  },
                  child: Text("Add playlist", style: smallBody),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: ThemeData(
          appBarTheme: const AppBarTheme(
        color: darkPurple,
      )),
      child: SizedBox.expand(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: 70.heightBox,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Text(
                      "Playlists",
                      style: mediumTitle,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: SizedBox(
                      height: 100,
                      child: ValueListenableBuilder(
                          valueListenable: hiveRepo.playListBox.listenable(),
                          builder: (context, val, child) {
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                if (index == val.length) {
                                  return MaterialButton(
                                    onPressed: () {
                                      showAddPlaylist(context);
                                    },
                                    color: backGround,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          color: Colors.white54, width: 1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    minWidth: 100,
                                    padding: const EdgeInsets.all(15),
                                    child: const Icon(Icons.add,
                                        size: 30, color: Colors.white),
                                  );
                                }
                                final item =
                                    CPlaylist.fromJson(val.getAt(index));
                                return Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: MaterialButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PlaylistPage(playlist: item)),
                                      );
                                    },
                                    color: purple,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    minWidth: 100,
                                    child: Text(item.name, style: smallTitle),
                                  ),
                                );
                              },
                              itemCount: val.length + 1,
                            );
                          }),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Text(
                      "All Songs",
                      style: mediumTitle,
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: hiveRepo.songBox.listenable(),
                  builder: (context, val, child) {
                    final items = val.values
                        .toList()
                        .map((e) => LocalVideo.fromJson(e))
                        .toList();
                    if (items.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Search for songs and download them",
                            style: smallTitle.copyWith(color: Colors.white54),
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildListDelegate(
                        items.mapIndexed(
                          (currentValue, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
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
                                        hiveRepo.deleteSong(currentValue);
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        itemBuilder: (context) {
                                          return hiveRepo.playListKeys.map(
                                            (e) {
                                              return PopupMenuItem(
                                                onTap: () {
                                                  hiveRepo.addSongToPlaylist(
                                                      e, currentValue);
                                                },
                                                value: e,
                                                child:
                                                    Text(e, style: smallBody),
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
                                          child: const Icon(Icons.playlist_add,
                                              color: Colors.white),
                                        ),
                                      ),
                                      15.widthBox,
                                      MaterialButton(
                                        minWidth: 0,
                                        padding: const EdgeInsets.all(5),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        onPressed: () {
                                          AudioControls.playSong(
                                              currentValue, ref);
                                        },
                                        color: purple,
                                        shape: const CircleBorder(),
                                        child: const Icon(
                                            Icons.play_arrow_rounded,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    );
                  },
                )
              ],
            ),
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () async {
                  final result = await showSearch<Video?>(
                      context: context, delegate: YTSearch());
                  if (result == null) return;

                  final sep = Platform.pathSeparator;

                  LocalVideo localVideo = LocalVideo(
                    id: result.id.value,
                    name: result.title,
                    author: result.author,
                    thumbnail: result.thumbnails.highResUrl,
                    path:
                        "${(await getApplicationDocumentsDirectory()).path}${sep}music$sep${result.id}.mp3",
                  );
                  context.showToast(
                      msg: "Downloading will appear here after done");
                  final downStream = ytRepo.downloadVideo(localVideo);
                  final sub = downStream.listen(
                    (event) {},
                    onDone: () {
                      hiveRepo.addSong(localVideo);
                    },
                    onError: (err) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Error Downloading")));
                    },
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    // boxShadow: const [
                    //   BoxShadow(
                    //     color: Colors.black54,
                    //     spreadRadius: 1,
                    //     blurRadius: 12,
                    //     blurStyle: BlurStyle.outer,
                    //   ),
                    // ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Search for any youtube video",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Icon(
                        Icons.search_sharp,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YTSearch extends SearchDelegate<Video?> {
  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear),
        )
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text("Nothing to show"),
      );
    }
    return Container(
      color: backGround,
      child: FutureBuilder(
          future: ytRepo.getSearchQuery(query),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.data == null) {
              return const Center(
                child: Text("Sorry Bad Results"),
              );
            }

            if (context.screenWidth > 480) {
              return SizedBox.expand(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 240,
                      mainAxisExtent: 380,
                      // childAspectRatio: 0.7,6
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    return GestureDetector(
                      onTap: () {
                        close(context, item);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Image.network(
                                  item.thumbnails.mediumResUrl,
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  right: 8,
                                  bottom: 8,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                    ),
                                    child: Text(
                                      item.duration != null
                                          ? "${item.duration!.inMinutes}:${item.duration!.inSeconds % 60}"
                                          : "None",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            5.heightBox,
                            Text("Title : ${item.title}", style: smallTitle),
                            Text("Author : ${item.author}", style: smallBody),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return SizedBox.expand(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];

                  return GestureDetector(
                    onTap: () {
                      close(context, item);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Image.network(
                                item.thumbnails.mediumResUrl,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                  ),
                                  child: Text(
                                    item.duration != null
                                        ? "${item.duration!.inMinutes}:${item.duration!.inSeconds % 60}"
                                        : "None",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          5.heightBox,
                          Text("Title : ${item.title}", style: smallTitle),
                          Text("Author : ${item.author}", style: smallBody),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: snapshot.data!.length,
              ),
            );
          }),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => Container(color: backGround);
}
