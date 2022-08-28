class MusicModel{
  late int id;
  late String name;
  late String author;
  late String thumbnail;
  late String url;

  MusicModel.fromMap(Map<String,dynamic> json){
    id = json["rid"]!;
    name = json["name"].toString();
    author = json["artist"].toString();
    thumbnail = json["pic"].toString();
    url = json["url"].toString();
  }

  @override
  String toString() {
    return 'MusicModel{id: $id, name: $name, author: $author, thumbnail: $thumbnail, url: $url}';
  }
}