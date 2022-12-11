import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:youtube_riverpod/search_page.dart';
import 'package:youtube_riverpod/styles/colors.dart';

import 'providers.dart';

class AllPages extends ConsumerWidget {
  const AllPages({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioP = ref.watch(audioProvider);
    debugPrint("All Pages = ${audioP == null}");

    return Container(
      color: backGround,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: backGround,
          body: Column(
            children: [
              Expanded(
                child: SearchPage(),
              ),
              audioP != null ? 70.heightBox : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
