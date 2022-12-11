import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:youtube_riverpod/models/local_video.dart';

class CPlaylist {
  final String name;
  final List<LocalVideo> list;
  CPlaylist({
    required this.name,
    required this.list,
  });

  CPlaylist copyWith({
    String? name,
    List<LocalVideo>? list,
  }) {
    return CPlaylist(
      name: name ?? this.name,
      list: list ?? this.list,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'list': list.map((x) => x.toMap()).toList()});

    return result;
  }

  factory CPlaylist.fromMap(Map<String, dynamic> map) {
    return CPlaylist(
      name: map['name'] ?? '',
      list: List<LocalVideo>.from(map['list']?.map((x) => LocalVideo.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory CPlaylist.fromJson(String source) => CPlaylist.fromMap(json.decode(source));

  @override
  String toString() => 'Playlist(name: $name, list: $list)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CPlaylist && other.name == name && listEquals(other.list, list);
  }

  @override
  int get hashCode => name.hashCode ^ list.hashCode;
}
