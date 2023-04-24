import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:pure_music/config/apis/api.dart';
import 'package:pure_music/model/song_model.dart';
import 'package:pure_music/ui/page/albums_page.dart';

class AlbumList extends StatefulWidget {
  AlbumList({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _AlbumListState createState() => _AlbumListState();
}

class _AlbumListState extends State<AlbumList> with TickerProviderStateMixin {
  TabController tabController;
  List<RcmPlayList> rcmPlayList = [];
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() => tabListener());
  }

  void tabListener() {
    // print(tabController.index);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = window.physicalSize.height;
    return Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        child: Expanded(
            child: Column(
          children: [
            AppBar(
              toolbarHeight: height * 0.02,
              title: Text(widget.title),
            ),
            GFTabs(
              height: height * 0.3,
              controller: tabController,
              length: 3,
              tabBarColor: Colors.blue,
              tabs: <Widget>[
                Tab(
                  child: Text(
                    "最新",
                  ),
                ),
                Tab(
                  child: Text(
                    "最热",
                  ),
                ),
                Tab(
                  child: Text(
                    "抖音",
                  ),
                ),
              ],
              tabBarView: GFTabBarView(
                controller: tabController,
                children: <Widget>[
                  Container(
                    child: CustomGridView(
                      tabController: tabController,
                    ),
                  ),
                  Container(
                    child: CustomGridView(tabController: tabController),
                  ),
                  Container(
                    child: CustomGridView(tabController: tabController),
                  ),
                ],
              ),
            ),
          ],
        )));
  }
}

class CustomGridView extends StatefulWidget {
  List<RcmPlayList> rcmPlayList = [];

  TabController tabController;

  CustomGridView({this.tabController});

  @override
  _CustomGridViewState createState() => _CustomGridViewState();
}

class _CustomGridViewState extends State<CustomGridView> {
  List<RcmPlayList> rcmPlayList = [];
  int index;
  @override
  void initState() {
    rcmPlayList = widget.rcmPlayList;
    index = widget.tabController.index;
    super.initState();
    loadRcmPlayList(index);
  }

  Future<void> loadRcmPlayList(int index) async {
    List<RcmPlayList> newRcmPlayList =
        await API.getRcmPlayList(page: index + 1);
    if (mounted) {
      setState(() {
        rcmPlayList = newRcmPlayList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 20,
        children:
            rcmPlayList.map((rcmPlayList) => _buildItem(rcmPlayList)).toList(),
      ),
    );
  }

  GestureDetector _buildItem(RcmPlayList rcmPlayList) => GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => AlbumsPage(data: rcmPlayList)));
      },
      child: Container(
        padding: EdgeInsets.all(6),
        alignment: Alignment.center,
        width: 100,
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image(
                height: 120.0,
                width: 120.0,
                image: CachedNetworkImageProvider(rcmPlayList.pic),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              rcmPlayList.name,
              style: TextStyle(
                  inherit: false,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ));
}
