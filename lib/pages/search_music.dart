import 'package:flutter/material.dart';
import 'package:pure_music/apis/api.dart';

class SearchBar extends StatefulWidget {
  SearchBar({Key? key, required this.hintLabel}) : super(key: key);

  final String hintLabel;

  @override
  State<StatefulWidget> createState() {
    return SearchAppBarState();
  }
}

class SearchAppBarState extends State<SearchBar> {
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
      searchMusic();
    });
  }

  _updateDelIconVisible(bool isVisible) {
    setState(() {
      _offstage = !isVisible;
    });
  }

  void searchMusic() async {
    print('搜索条件：' + _textEditingController.text);
    if (_textEditingController.text != null && _textEditingController.text != '') {
      List res = await MusicAPI().search(_textEditingController.text);
    }
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
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                  ),
                  Icon(
                    Icons.search_sharp,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _textEditingController,
                      autofocus: true,
                      focusNode: _focusNode,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      decoration: InputDecoration(hintText: widget.hintLabel),
                      maxLines: 1
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                  ),
                  Offstage(
                    offstage: _offstage,
                    child: GestureDetector(
                        onTap: () => {_textEditingController.clear()},
                        child: Icon(
                          Icons.cancel_outlined,
                          size: 20,
                          color: Theme.of(context).primaryColor,
                        )),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                  ),
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
                  style: TextStyle(fontSize: 16, color: Color(0xFF3D7DFF), )),
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