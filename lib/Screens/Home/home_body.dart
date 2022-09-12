import 'package:flutter/material.dart';
import 'package:pure_music/CustomWidgets/animated_text.dart';
import 'package:pure_music/Screens/Top%20Charts/top.dart';
import 'package:pure_music/apis/api.dart';

/**
 *
 * 首页内容
 */

bool fetched = false;

class HomeBody extends StatefulWidget {
  List rcmPlayList = [];

  @override
  HomeBodyState createState() => HomeBodyState();
}

class HomeBodyState extends State<HomeBody> {
  Future<void> getHomePageData() async {
    widget.rcmPlayList = await API().getRcmPlayList(1, 6);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!fetched || widget.rcmPlayList.length == 0) {
      getHomePageData();
      fetched = true;
    }
    return Scaffold(
        body: Column(
        children: [
          Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          child: Column(
            children: [
              ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    // textColor: const Color(0xFF6200EE),
                    onPressed: () {
                      // Perform some action
                    },
                    child: Column(
                      children: [
                        const Icon(Icons.person),
                        Text('歌手'),
                      ],
                    ),
                  ),
                  TextButton(
                    // textColor: const Color(0xFF6200EE),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => TopCharts())),
                    child: Column(
                      children: [
                        const Icon(Icons.leaderboard),
                        Text('排行榜'),
                      ],
                    ),
                  ),
                  TextButton(
                    // textColor: const Color(0xFF6200EE),
                    onPressed: () {
                      // Perform some action
                    },
                    child: Column(
                      children: [
                        const Icon(Icons.queue_music_outlined),
                        Text('分类歌单'),
                      ],
                    ),
                  ),
                  TextButton(
                    // textColor: const Color(0xFF6200EE),
                    onPressed: () {
                      // Perform some action
                    },
                    child: Column(
                      children: [
                        const Icon(Icons.radio),
                        Text('电台'),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          child: Column(
            children: [
              ListTile(
                title: const Text('歌单推荐'),
                trailing: const Text('更多'),
              ),
              GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: MediaQuery.of(context).size.width >
                          MediaQuery.of(context).size.height? 6 : 3,
                  physics: const BouncingScrollPhysics(),
                  childAspectRatio: 0.9,
                  children: widget.rcmPlayList.map((e) {
                    return TextButton(
                      onPressed: () {
                        // Perform some action
                      },
                      child: Column(
                        children: [
                          Image.network(
                            '${e['img']}',
                            width: 90,
                            height: 90,
                            fit: BoxFit.fitWidth,
                          ),
                          Text('${e['name'].toString().substring(0, 5)}'),
                          // AnimatedText(
                          //   text: '${e['name']}',
                          //   pauseAfterRound: const Duration(seconds: 3),
                          //   showFadingOnlyWhenScrolling: false,
                          //   fadingEdgeEndFraction: 0.1,
                          //   fadingEdgeStartFraction: 0.1,
                          //   startAfter: const Duration(seconds: 2),
                          // ),
                          // Expanded(child: Text('${e['name']}')),
                        ],
                      ),
                    );
                  }).toList()),
            ],
          ),
        ),
      ],
    ));
  }
}
