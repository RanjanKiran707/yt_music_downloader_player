import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_riverpod/data/hive_repo.dart';
import 'package:youtube_riverpod/data/youtube_repo.dart';
import 'package:youtube_riverpod/nav_page.dart';

_initHive() async {
  await Hive.initFlutter();
  await Hive.openBox("songs");

  //Open All PlayList boxes
  await Hive.openBox("playlists");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory("${(await getApplicationDocumentsDirectory()).path}/music").createSync();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await _initHive();
  runApp(const ProviderScope(child: MyApp()));
}

final navigatorKey = GlobalKey<NavigatorState>();
final ytRepo = YoutubeRepository();
final hiveRepo = HiveRepo();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Music Player",
      home: NavPage(),
    );
  }
}
