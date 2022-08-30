import 'package:flutter/material.dart';
import 'package:pure_music/apis/api.dart';
import 'EventBus.dart';

class SearchBar2 extends StatefulWidget {
  SearchBar2({Key? key, required this.hintLabel}) : super(key: key);
  final String hintLabel;

  @override
  State<StatefulWidget> createState() => SearchBar2State();
}

class SearchBar2State extends State<SearchBar2> {
  late FocusNode _focusNode;
  bool _offstage = true;
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
    if (_textEditingController.text != null &&
        _textEditingController.text != '') {
      print('搜索条件：' + _textEditingController.text);
      eventBus.fire(
          CustomEvent(await MusicAPI().searchBykeyWord(_textEditingController.text)));
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
                    color: Colors.grey,
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
                        decoration: InputDecoration(
                            hintText: widget.hintLabel,
                            hintStyle: const TextStyle(height: 1.05),
                            enabledBorder: new UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0x19000000)),
                            ),
                            focusedBorder: new UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0x19000000)))
                            // height: 10,
                            ),
                        maxLines: 1),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                  ),
                  Offstage(
                    offstage: _offstage,
                    child: GestureDetector(
                        onTap: () => {_textEditingController.clear()},
                        child: Icon(
                          Icons.cancel_sharp,
                          size: 20,
                          color: Colors.grey,
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
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  )),
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
