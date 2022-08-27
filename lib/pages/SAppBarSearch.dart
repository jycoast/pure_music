import 'package:flutter/material.dart';
import 'package:pure_music/apis/api.dart';

class SearchWidget extends StatefulWidget {
  final double? height; // 高度
  final double? width; // 宽度
  final String? hintText; // 输入提示
  final ValueChanged<String>? onEditingComplete; // 编辑完成的事件回调

  const SearchWidget(
      {Key? key,
      this.height,
      this.width,
      this.hintText,
      this.onEditingComplete})
      : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  var controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  /// 清除查询关键词
  clearKeywords() async {
    // controller.text = "";
    print(controller.text);
    var url = await MusicAPI().getPlayUrl('226543302');
    print(url);
  }

  @override
  Widget build(BuildContext context) {
    var width = widget.width ?? MediaQuery.of(context).size.width * 8 / 10;
    var height = widget.width ?? widget.height ?? 30;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(height),
      ),
      child: TextField(
          controller: controller,
          decoration: InputDecoration(
              hintText: widget.hintText ?? "请输入搜索词",
              hintStyle: TextStyle(color: Colors.black, fontSize: 14),
              contentPadding:
                  EdgeInsets.only(top: -height / 5, left: width / 15),
              border: InputBorder.none,
              icon: Padding(
                  padding: EdgeInsets.only(left: width / 15, top: height / 5),
                  child: Icon(
                    Icons.search,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  )),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 20,
                ),
                onPressed: clearKeywords,
                splashColor: Theme.of(context).primaryColor,
              )),
          onEditingComplete: () {
            widget.onEditingComplete?.call(controller.text);
          }),
    );
  }
}
