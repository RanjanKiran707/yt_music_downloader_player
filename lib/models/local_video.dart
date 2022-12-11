import 'dart:convert';

class LocalVideo {
  final String name;
  final String author;
  final String thumbnail;
  final String path;
  final String id;
  LocalVideo({
    required this.name,
    required this.author,
    required this.thumbnail,
    required this.path,
    required this.id,
  });

  LocalVideo copyWith({
    String? name,
    String? author,
    String? thumbnail,
    String? path,
    String? id,
  }) {
    return LocalVideo(
      name: name ?? this.name,
      author: author ?? this.author,
      thumbnail: thumbnail ?? this.thumbnail,
      path: path ?? this.path,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'name': name});
    result.addAll({'author': author});
    result.addAll({'thumbnail': thumbnail});
    result.addAll({'path': path});
    result.addAll({'id': id});

    return result;
  }

  factory LocalVideo.fromMap(Map<String, dynamic> map) {
    return LocalVideo(
      name: map['name'] ?? '',
      author: map['author'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      path: map['path'] ?? '',
      id: map['id'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory LocalVideo.fromJson(String source) => LocalVideo.fromMap(json.decode(source));

  @override
  String toString() {
    return 'LocalVideo(name: $name, author: $author, thumbnail: $thumbnail, path: $path, id: $id)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocalVideo &&
        other.name == name &&
        other.author == author &&
        other.thumbnail == thumbnail &&
        other.path == path &&
        other.id == id;
  }

  @override
  int get hashCode {
    return name.hashCode ^ author.hashCode ^ thumbnail.hashCode ^ path.hashCode ^ id.hashCode;
  }
}
