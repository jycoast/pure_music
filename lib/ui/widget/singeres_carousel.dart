import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pure_music/generated/i18n.dart';
import 'package:pure_music/model/song_model.dart';
import 'package:pure_music/ui/page/albums_page.dart';

import '../page/singeres_page.dart';

class SingeresCarousel extends StatefulWidget {
  final List<Singer> singeres;

  SingeresCarousel(this.singeres);
  @override
  _SingeresCarouselState createState() => _SingeresCarouselState();
}

class _SingeresCarouselState extends State<SingeresCarousel> {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(S.of(context).singer,
                style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            GestureDetector(
              onTap: () => {
                print('View All'),
              },
              child: Text(S.of(context).viewAll,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ),
      ),
      Column(
        children: <Widget>[
          Container(
            height: 180,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: widget.singeres.length,
              itemBuilder: (BuildContext context, int index) {
                Singer data = widget.singeres[index];
                return GestureDetector(
                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SingeresPage(
                          data: data,
                        ),
                      ),
                    ),
                  },
                  child: Container(
                    width: 140,
                    margin: index == widget.singeres.length - 1
                        ? EdgeInsets.only(right: 20.0)
                        : EdgeInsets.only(right: 0.0),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image(
                              height: 120.0,
                              width: 120.0,
                              image: CachedNetworkImageProvider(data.pic),
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            data.name,
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      )
    ]);
  }
}
