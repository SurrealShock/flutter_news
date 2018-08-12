import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_news/main.dart';
import 'package:flutter_news/navigation/search.dart';
import 'package:flutter_news/navigation/widgets.dart';
import 'package:flutter_news/utilities/bookMarkItem.dart';
import 'package:flutter_news/utilities/firebase.dart';
import 'package:flutter_news/utilities/url_launch.dart';

class BookMarks extends StatefulWidget {
  @override
  BookMarkState createState() => BookMarkState();
}

class BookMarkState extends State<BookMarks> {
  FirebaseUser user;
  DatabaseReference reference;
  List<BookMarkItem> bookMarkItem = [];
  var data = Map();
  var data2 = Map();
  Key sliverKey = Key('sliverKey');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          sliverAppBar(context, 'Bookmarks'),
          FutureBuilder(
            future: Auth.getUser(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SliverList(
                  key: sliverKey,
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
                        child: GestureDetector(
                          onTap: () {
                            launchURL(bookMarkItem[index].articleURL);
                          },
                          child: NewsContainer(
                              child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(children: <Widget>[
                              NewsCard(
                                  bookMarkItem: bookMarkItem[index],
                                  showDate: false,
                                  customPopUpMenu: PopupMenuButton<int>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      size: 20.0,
                                      color: Colors.grey[700],
                                    ),
                                    padding: EdgeInsets.zero,
                                    onSelected: (_) {
                                      switch (_) {
                                        case 0:
                                          if (!data.containsKey(
                                              bookMarkItem[index].title)) {
                                            bookMark(bookMarkItem[index]);
                                          } else {
                                            BookMarkItem.removeBookMark(
                                                Auth.getDatabase()
                                                    .reference()
                                                    .child('users/' + user.uid)
                                                    .child('/' +
                                                        data[bookMarkItem[index]
                                                            .title]));
                                          }
                                          break;
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      bool bookmarked = data.containsKey(
                                          bookMarkItem[index].title);
                                      return <PopupMenuEntry<int>>[
                                        PopupMenuItem<int>(
                                          value: 0,
                                          child: Row(
                                            children: <Widget>[
                                              Icon(bookmarked
                                                  ? Icons.bookmark
                                                  : Icons.bookmark_border),
                                              Text(bookmarked
                                                  ? "Remove bookmark"
                                                  : "  Bookmark")
                                            ],
                                          ),
                                        ),
                                      ];
                                    },
                                  )),
                            ]),
                          )),
                        ),
                      );
                    },
                    childCount: bookMarkItem.length,
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return LoadingCard();
                }, childCount: 10),
              );
            },
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    final FirebaseDatabase firebaseDatabase = Auth.getDatabase();
    Auth.getUser().then((u) {
      user = u;
      reference = firebaseDatabase.reference().child('users/' + user.uid);
      reference.onChildAdded.listen(_onEntryAdded);
      reference.onChildRemoved.listen(_onEntryRemoved);
    });
    super.initState();
  }

  _onEntryAdded(Event event) {
    data[event.snapshot.value['title']] = event.snapshot.key;
    bookMarkItem.add(BookMarkItem.fromSnapshot(event.snapshot.value));
  }

  _onEntryRemoved(Event event) {
    bookMarkItem.removeWhere((bookMarkItem) {
      return bookMarkItem.title ==
          BookMarkItem.fromSnapshot(event.snapshot.value).title;
    });
    data.remove(event.snapshot.value['title']);
    setState(() {
      bookMarkItem.length;
    });
  }

  void bookMark(BookMarkItem bMrkItm) async {
    reference.push().set(bMrkItm.toJson());
  }
}
