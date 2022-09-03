import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pure_music/theme/app_theme.dart';

/**
 * 我的页面
 * https://www.coolcou.com/flutter-tutorial/flutter-page-layout/flutter-padding.html
 */
class Person extends StatefulWidget {
  @override
  PersonState createState() => PersonState();
}

class PersonState extends State<Person> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        // ),
        body: Column(
          children: [
            Card(
              elevation: 0,
              child: TextButton(
                onPressed: () {  },
                child: Row(
                    children:[
                      const Icon(Icons.login),
                      Padding(padding: const EdgeInsets.only(left: 25)),
                      Text('点击登录',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 18.0,
                            height: 1.2,
                            // decoration:TextDecoration.underline,
                            // decorationStyle: TextDecorationStyle.dashed
                        ))
                    ]
                ),
              )
            ),
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
                            const Icon(Icons.music_note),
                            Text('本地'),
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
                            const Icon(Icons.download),
                            Text('下载'),
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
                            const Icon(Icons.access_time_sharp),
                            Text('最近播放'),
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
                            const Icon(Icons.favorite_rounded),
                            Text('我喜欢'),
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
                    title: const Text('自建歌单'),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
