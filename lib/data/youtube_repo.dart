import 'dart:io';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_riverpod/models/local_video.dart';

class YoutubeRepository {
  YoutubeHttpClient client = YoutubeHttpClient();
  var yt = YoutubeExplode();

  Future<List<Video>> getSearchQuery(String q) async {
    final srchClient = SearchClient(client);

    final list = await srchClient.search(q, filter: TypeFilters.video);

    final List<Video> newList = [];

    for (var i in list) {
      newList.add(i);
    }
    return newList;
  }

  Stream<int> downloadVideo(LocalVideo localVideo) async* {
    var manifest = await yt.videos.streamsClient.getManifest(localVideo.id);

    var streamInfo = manifest.audioOnly.withHighestBitrate();
    final length = streamInfo.size.totalBytes;
    var stream = yt.videos.streamsClient.get(streamInfo);

    var file = File(localVideo.path);
    int count = 0;
    var fileStream = file.openWrite(mode: FileMode.writeOnlyAppend);
    await for (final data in stream) {
      count += data.length;
      int progress = ((count / length) * 100).ceil();

      fileStream.add(data);
      yield progress;
    }

    await fileStream.flush();
    await fileStream.close();
  }
}
