import 'package:flutter/material.dart';
import 'package:pure_music/apis/api.dart';
import '../utils/music_data_util.dart';

class SearchMusic extends StatefulWidget {
  SearchMusic({Key? key, required this.hintLabel}) : super(key: key);

  final String hintLabel;

  @override
  State<StatefulWidget> createState() {
    return SearchAppBarState();
  }
}

class SearchAppBarState extends State<SearchMusic> {
  late FocusNode _focusNode;
  ///默认不展示控件
  bool _offstage = true;

  ///监听TextField内容变化
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _textEditingController.addListener(() {
      var isVisible = _textEditingController.text.isNotEmpty;
      _updateDelIconVisible(isVisible);
      _search(_textEditingController.text);
    });
  }

  _updateDelIconVisible(bool isVisible) {
    print('_updateDelIconVisible invoke');
    setState(() {
      _offstage = !isVisible;
    });
  }

  _search(String text) async {
    print('搜索文字:' + text);
    MusicAPI().search(text);
    // SinglePage().createState().mounted;
    // List value = await MusicAPI().search(text);
    // print(value);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 30,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: double.infinity,
              margin: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // paddingOnly(const EdgeInsets.only(left: 8)),
                  // Image.asset(
                  //   "assets/images/p8.png",
                  //   width: 16,
                  //   height: 16,
                  // ),

                  // paddingOnly(const EdgeInsets.only(left: 8)),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _textEditingController,
                      autofocus: true,
                      focusNode: _focusNode,
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      decoration: InputDecoration(),
                      maxLines: 1,
                    ),
                  ),
                  // paddingOnly(const EdgeInsets.only(right: 8)),
                  Offstage(
                    offstage: _offstage,
                    child: GestureDetector(
                      onTap: () => {_textEditingController.clear()},
                      // child: Image.asset(
                      //   "images/home_search_cancel.png",
                      //   width: 16,
                      //   height: 16,
                      // ),
                    ),
                  ),
                  // paddingOnly(const EdgeInsets.only(right: 8),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _focusNode.unfocus();
            },
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Text("取消",
                  style: TextStyle(fontSize: 16, color: Color(0xFF3D7DFF))),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.unfocus();
  }
}