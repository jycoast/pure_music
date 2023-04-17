import 'package:flutter/material.dart';
import 'package:pure_music/ui/widget/album_carousel.dart';
import 'package:pure_music/ui/widget/app_bar.dart';
import 'package:pure_music/model/song_model.dart';

import '../widget/singer_carousel.dart';

class SingeresPage extends StatefulWidget {
  final Singer data;

  SingeresPage({this.data});

  @override
  _SingeresPageState createState() => _SingeresPageState();
}

class _SingeresPageState extends State<SingeresPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: <Widget>[
          AppBarCarousel(),
          Expanded(
            child: ListView(
              children: <Widget>[
                Center(
                    child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.5,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Container(child: Image.network(widget.data.pic))),
                )),
                SizedBox(height: 20.0),
                Center(
                  child: Text(
                    widget.data.name,
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 70,
                        margin: EdgeInsets.only(
                            top: 20, bottom: 20, left: 20, right: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12, width: 1),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.play_arrow,
                              color: Theme.of(context).accentColor,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Play',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 70,
                        margin: EdgeInsets.only(
                            top: 20, bottom: 20, left: 10, right: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12, width: 1),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.add),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Add'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SingerCarousel(input: widget.data.name),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
