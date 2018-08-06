import 'package:firebase_database/firebase_database.dart';

/// BookMarkItem keeps track of the current values displayed on the cards
class BookMarkItem {
  String key;
  String title;
  String description;
  String imageURL;
  String source;
  String articleURL;
  String published;

  BookMarkItem(this.title, this.description, this.imageURL, this.source,
      this.articleURL, this.published);
  factory BookMarkItem.fromSnapshot(DataSnapshot snapshot) {
    return BookMarkItem(
        snapshot.value['title'],
        snapshot.value['description'],
        snapshot.value['imageURL'],
        snapshot.value['source'],
        snapshot.value['articleURL'],
        snapshot.value['publishedAt']);
  }

  factory BookMarkItem.fromJson(Map j) {
    return BookMarkItem(j['title'], j['description'] ?? "", j['urlToImage'],
        j['source']['name'], j['url'], j['publishedAt']);
  }

  toJson() {
    return {
      'title': title,
      'description': description,
      'imageURL': imageURL,
      'source': source,
      'articleURL': articleURL,
      'publishedAt': published,
    };
  }

  static removeBookMark(DatabaseReference ref) async {
    ref.remove();
  }
}
