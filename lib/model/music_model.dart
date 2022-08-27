/// Created by RongCheng on 2022/3/2.

class MusicModel{
  late int id;
  late String name;
  late String author;
  late String thumbnail;
  late String url;

  MusicModel.fromMap(Map<String,dynamic> json){
    id = json["id"];
    name = json["name"];
    author = json["author"];
    thumbnail = json["thumbnail"];
    url = json["url"];
  }
}