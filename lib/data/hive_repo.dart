import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:youtube_riverpod/models/local_video.dart';
import 'package:youtube_riverpod/models/playlist.dart';

class HiveRepo {
  addSong(LocalVideo localVideo) async {
    await Hive.box("songs").add(localVideo.toJson());
  }

  deleteSong(LocalVideo localVideo) async {
    for (int i in songBox.keys) {
      if (LocalVideo.fromJson(songBox.get(i)) == localVideo) {
        songBox.delete(i);
        File(localVideo.path).delete();
      }
    }

    for (var i in playListBox.keys) {
      final playlist = CPlaylist.fromJson(playListBox.get(i));
      if (playlist.list.contains(localVideo)) {
        playlist.list.remove(localVideo);
        addPlaylist(playlist);
      }
    }
  }

  addPlaylist(CPlaylist playlist) {
    playListBox.put(playlist.name, playlist.toJson());
  }

  addSongToPlaylist(String name, LocalVideo localVideo) async {
    CPlaylist playlist = CPlaylist.fromJson(playListBox.get(name));
    if (!playlist.list.contains(localVideo)) {
      playlist.list.add(localVideo);
      await playListBox.put(name, playlist.toJson());
    }
  }

  deleteSongFromPlaylist(String name, LocalVideo localVideo) async {
    CPlaylist playlist = CPlaylist.fromJson(playListBox.get(name));
    if (playlist.list.contains(localVideo)) {
      playlist.list.remove(localVideo);
      await playListBox.put(name, playlist.toJson());
    }
  }

  changePlaylistOrder(CPlaylist playlist) {
    playListBox.put(playlist.name, playlist.toJson());
  }

  List get playListKeys {
    return playListBox.keys.toList();
  }

  Box get songBox {
    return Hive.box("songs");
  }

  Box get playListBox {
    return Hive.box("playlists");
  }
}
