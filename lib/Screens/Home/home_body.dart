import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pure_music/CustomWidgets/animated_text.dart';
import 'package:pure_music/theme/app_theme.dart';

/**
 *
 * 首页内容
 */
class HomeBody extends StatefulWidget {
  @override
  HomeBodyState createState() => HomeBodyState();
}

class HomeBodyState extends State<HomeBody> {
  @override
  Widget build(BuildContext context) {
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
                            const Icon(Icons.person, color: Colors.lightGreen),
                            Text('歌手'),
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
                            Text('歌单'),
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
            // Image.asset('assets/card-sample-image.jpg'),
            Card(
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('歌单推荐'),
                    trailing:const Text('更多'),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Perform some action
                        },
                        child: Column(
                          children: [
                            Image.network(
                              'https://img1.kuwo.cn/star/userpl2015/12/59/1652780728468_474818612_500.jpg',
                              width: 50,
                              height: 50,
                              fit: BoxFit.fitWidth,
                            ),
                            Text('五杀神'),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Perform some action
                        },
                        child: Column(
                          children: [
                            Image.network(
                              'https://img1.kuwo.cn/star/userpl2015/12/59/1652780728468_474818612_500.jpg',
                              width: 50,
                              height: 50,
                              fit: BoxFit.fitWidth,
                            ),
                            // Image.network(
                            //   'https://i.pinimg.com/originals/7d/8f/34/7d8f34dc8ea9d452ec2d10e4844efc69.jpg',
                            // ),
                            Text('五杀神曲'),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Perform some action
                        },
                        child: Column(
                          children: [
                            Image.network(
                              'https://img1.kuwo.cn/star/userpl2015/12/59/1652780728468_474818612_500.jpg',
                              width: 50,
                              height: 50,
                              fit: BoxFit.fitWidth,
                            ),
                            // Image.network(
                            //   'https://i.pinimg.com/originals/7d/8f/34/7d8f34dc8ea9d452ec2d10e4844efc69.jpg',
                            // ),
                            Text('五杀神曲'),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Perform some action
                        },
                        child: Column(
                          children: [
                            Image.network(
                              'https://img1.kuwo.cn/star/userpl2015/12/59/1652780728468_474818612_500.jpg',
                              width: 50,
                              height: 50,
                              fit: BoxFit.fitWidth,
                            ),
                            // Image.network(
                            //   'https://i.pinimg.com/originals/7d/8f/34/7d8f34dc8ea9d452ec2d10e4844efc69.jpg',
                            // ),
                            Text('五杀神曲'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
