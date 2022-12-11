import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_riverpod/all_pages.dart';
import 'package:youtube_riverpod/main.dart';
import 'package:youtube_riverpod/mini_widget.dart';

class NavPage extends ConsumerWidget {
  const NavPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          Navigator(
            key: navigatorKey,
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                settings: settings,
                builder: (context) {
                  return const AllPages();
                },
              );
            },
          ),
          const MiniPWidget(),
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: purple,
      //   showSelectedLabels: false,
      //   showUnselectedLabels: false,
      //   currentIndex: curIndex,
      //   onTap: (index) {
      //     ref.read(navIndexProvider.notifier).state = index;
      //   },
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(
      //         Icons.home_filled,
      //         color: Colors.white,
      //       ),
      //       label: "Home",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(
      //         Iconsax.document_download,
      //         color: Colors.white,
      //       ),
      //       label: "Downloads",
      //     )
      //   ],
      // ),
    );
  }
}
