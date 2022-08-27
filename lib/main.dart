import 'package:flutter/material.dart';
import 'package:pure_music/utils/music_data_util.dart';
import 'package:pure_music/widgets/audio_show_veiw.dart';

import 'package:pure_music/pages/single_page.dart';
import 'package:pure_music/pages/list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const AppTabBarWidget(),
    );
  }
}

class AppTabBarWidget extends StatefulWidget {
  const AppTabBarWidget({Key? key}) : super(key: key);

  @override
  State<AppTabBarWidget> createState() => _AppTabBarWidgetState();
}

class _AppTabBarWidgetState extends State<AppTabBarWidget> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  late List<BottomNavigationBarItem> _items;
  late List<Widget> _pages;

  @override
  void initState() {
    _items = [
      AppTabBarItem("单曲"),
      AppTabBarItem("目录"),
    ];
    _pages = [const SinglePage(), const ListPage()];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.black45,
        items: [
          AppTabBarItem("单曲"),
          AppTabBarItem("目录"),
        ],
        onTap: (int index) {
          _pageController.jumpToPage(index);
        },
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: _onPageChanged,
            itemCount: _items.length,
            itemBuilder: (BuildContext context, int index) {
              return _pages[index];
            },
          ),
          Positioned(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AudioShowView(
                context: context,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onPageChanged(int index) {
    if (_currentPage != index) {
      setState(() => _currentPage = index);
    }
  }
}

class AppTabBarItem extends BottomNavigationBarItem {
  AppTabBarItem(String title)
      : super(
            icon: title == "单曲"
                ? const Icon(Icons.home_outlined)
                : const Icon(Icons.list),
            activeIcon: title == "单曲"
                ? const Icon(Icons.home)
                : const Icon(Icons.view_list),
            label: title);
}
