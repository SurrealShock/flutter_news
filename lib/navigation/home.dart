import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_news/main.dart';
import 'package:flutter_news/navigation/search.dart';
import 'package:flutter_news/navigation/widgets.dart';
import 'package:flutter_news/utilities/api.dart';
import 'package:flutter_news/utilities/bookMarkItem.dart';
import 'package:flutter_news/utilities/fetch.dart';
import 'package:flutter_news/utilities/firebase.dart';
import 'package:flutter_news/utilities/url_launch.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final currentTime = DateTime.now();
  List<BookMarkItem> bookMarkItem = [];
  // ScrollController controller;
  DatabaseReference reference;
  FirebaseUser user;
  GetFromUrl getFromUrl = GetFromUrl();

  var data = Map();

  void bookMark(BookMarkItem bMrkItm) async {
    reference.push().set(bMrkItm.toJson());
  }

  // @override
  // void dispose() {
  //   controller.removeListener(_scrollListener);
  //   super.dispose();
  // }

  // _scrollListener() {
  //   print(controller.position.extentAfter);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('News'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator
                  .of(context)
                  .push(MaterialPageRoute(builder: (context) => Search()));
            },
            icon: Icon(Icons.search),
          ),
          StreamBuilder(
            stream: FirebaseAuth.instance.currentUser().asStream(),
            builder:
                (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
              if (snapshot.hasData) {
                return PopupMenuButton(
                  child: ProfilePicture(snapshot.data.photoUrl),
                  onSelected: (index) {
                    switch (index) {
                      case 0:
                        Auth.signOutFirebase();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) => MyApp()));
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    return <PopupMenuEntry<int>>[
                      PopupMenuItem(
                        value: 0,
                        child: Text('Sign out'),
                      )
                    ];
                  },
                );
              } else {
                return Container(
                  height: 0.0,
                  width: 0.0,
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: getFromUrl.fetch(
            "https://newsapi.org/v2/top-headlines?country=us&apiKey=" + apiKey),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data['totalResults'],
              itemBuilder: (context, index) {
                bookMarkItem.add(
                    BookMarkItem.fromJson(snapshot.data['articles'][index]));
                return Dismissible(
                  onDismissed: (direction) {
                    bookMarkItem.removeAt(index);
                  },
                  key: Key(bookMarkItem[index].articleURL),
                  child: Padding(
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
                                bookMarkItem,
                                index,
                                PopupMenuButton<int>(
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
                                              FirebaseDatabase.instance
                                                  .reference()
                                                  .child('users/' + user.uid)
                                                  .child('/' +
                                                      data[bookMarkItem[index]
                                                          .title]));
                                        }
                                        break;
                                      case 1:
                                        break;
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    bool bookmarked = data
                                        .containsKey(bookMarkItem[index].title);
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
                                      PopupMenuItem<int>(
                                        value: 1,
                                        child: Row(
                                          children: <Widget>[
                                            Icon(Icons.settings),
                                            Text("  Customize")
                                          ],
                                        ),
                                      ),
                                    ];
                                  },
                                ))
                          ]),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Container(
            height: 0.0,
            width: 0.0,
          );
          // return ListView.builder(
          //   itemCount: 10,
          //   itemBuilder: (context, index) {
          //     return LoadingCard(index + 5);
          //   });
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // controller = ScrollController()..addListener(_scrollListener);
    final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
    Auth.getUser().then((user) {
      this.user = user;
      reference = firebaseDatabase.reference().child('users/' + user.uid);
      reference.onChildAdded.listen(_onEntryAdded);
      reference.onChildRemoved.listen(_onEntryRemoved);
    });
  }

  _onEntryAdded(Event event) {
    data[event.snapshot.value['title']] = event.snapshot.key;
  }

  _onEntryRemoved(Event event) {
    data.remove(event.snapshot.value['title']);
  }
}
