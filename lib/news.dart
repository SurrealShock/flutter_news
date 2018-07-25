import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_news/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

bool loaded = false;
var loadedJson;

class News extends StatefulWidget {
  @override
  NewsState createState() => NewsState();
}

class NewsState extends State<News> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Disallow swiping back to login screen
      onWillPop: () => Future.value(false),
      child: MaterialApp(
        theme: ThemeData(
            textTheme: TextTheme(
                headline: TextStyle(fontSize: 15.0),
                body1: TextStyle(fontSize: 13.0, color: Colors.grey[600]))),
        home: Scaffold(
          // Create stack to load both pages
          body: Stack(
            children: <Widget>[
              // When not in use don't load graphics
              Offstage(
                offstage: index != 0,
                child: TickerMode(
                  enabled: index == 0,
                  child: MaterialApp(home: MyHome()),
                ),
              ),
              Offstage(
                offstage: index != 1,
                child: TickerMode(
                  enabled: index == 1,
                  child: MaterialApp(home: BookMarks()),
                ),
              ),
            ],
          ),
          // Create bottom navbar with home and bookmarks nav
          bottomNavigationBar: new BottomNavigationBar(
            currentIndex: index,
            onTap: (index) {
              setState(() {
                this.index = index;
              });
            },
            items: <BottomNavigationBarItem>[
              new BottomNavigationBarItem(
                icon: new Icon(Icons.home),
                title: new Text("Home"),
              ),
              new BottomNavigationBarItem(
                icon: new Icon(Icons.collections_bookmark),
                title: new Text("Bookmarks"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// BookMarkItem keeps track of the current values displayed on the cards
class BookMarkItem {
  String key;
  String title;
  String description;
  String imageURL;
  String source;
  String articleURL;

  BookMarkItem(this.title, this.description, this.imageURL, this.source,
      this.articleURL);
  BookMarkItem.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        title = snapshot.value['title'],
        description = snapshot.value['description'],
        imageURL = snapshot.value['imageURL'],
        source = snapshot.value['source'],
        articleURL = snapshot.value['articleURL'];

  toJson() {
    return {
      'title': title,
      'description': description,
      'imageURL': imageURL,
      'source': source,
      'articleURL': articleURL,
    };
  }
}

class MyHomeState extends State<MyHome> {
  final currentTime = new DateTime.now();
  List<BookMarkItem> items = List();
  BookMarkItem bookMarkItem;
  DatabaseReference reference;
  FirebaseUser user;
  var data = Map();

  @override
  void initState() {
    super.initState();
    bookMarkItem = BookMarkItem("", "", "", "", "");
    final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
    _getUser().then((user) {
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

  void bookMark() async {
    reference.push().set(bookMarkItem.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text('News'),
        actions: <Widget>[
          StreamBuilder(
            stream: FirebaseAuth.instance.currentUser().asStream(),
            builder:
                (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(96.0),
                      boxShadow: [
                        new BoxShadow(
                            color: Colors.black45,
                            blurRadius: 1.5,
                            offset: Offset(0.0, 1.0))
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(96.0),
                      child: Image.network(snapshot.data.photoUrl),
                    ),
                  ),
                );
              } else {
                return Container(
                  height: 0.0,
                  width: 0.0,
                );
              }
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: fetchFutureLaunches(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final jsonResponse = json.decode(snapshot.data.toString());
            return ListView.builder(
              itemCount: jsonResponse['totalResults'],
              itemBuilder: (context, index) {
                setBookmarkItem(jsonResponse, index);
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 12.0, bottom: 0.0),
                  child: GestureDetector(
                    onTap: () {
                      _launchURL(bookMarkItem.articleURL);
                    },
                    child: NewsCard(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(children: <Widget>[
                          Flexible(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        (currentTime.difference(DateTime.parse(
                                                    jsonResponse['articles']
                                                            [index]
                                                        ['publishedAt'])))
                                                .inHours
                                                .toString() +
                                            " hr ago · " +
                                            bookMarkItem.source,
                                        style: TextStyle(
                                            fontSize: 13.0,
                                            color: Colors.grey[700]),
                                      ),
                                      new PopupMenuButton<int>(
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
                                                  bookMarkItem.title)) {
                                                setBookmarkItem(
                                                    jsonResponse, index);
                                                bookMark();
                                              } else {
                                                removeBookMark(FirebaseDatabase
                                                    .instance
                                                    .reference()
                                                    .child('users/' + user.uid)
                                                    .child('/' +
                                                        data[bookMarkItem
                                                            .title]));
                                              }
                                              break;
                                            case 1:
                                              break;
                                          }
                                        },
                                        itemBuilder: (BuildContext context) {
                                          bool bookmark = data
                                              .containsKey(bookMarkItem.title);
                                          return <PopupMenuEntry<int>>[
                                            PopupMenuItem<int>(
                                              value: 0,
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(bookmark
                                                      ? Icons.bookmark
                                                      : Icons.bookmark_border),
                                                  Text(bookmark
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
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: CardText(
                                        title: bookMarkItem.title,
                                        body: bookMarkItem.description,
                                      )
                                    ),
                                    ImageContainer(
                                      url: bookMarkItem.imageURL,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return new Center(
              child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue)));
        },
      ),
    );
  }

  Future<String> fetchFutureLaunches() async {
    if (!loaded) {
      print("Got from URL.");
      final json = await http.get(
          "https://newsapi.org/v2/top-headlines?country=us&apiKey=792059e30e20494e94fd5a2e56fb4da4");
      loaded = true;
      loadedJson = json.body;
      return json.body;
    }
    print("Loaded from storage");
    return loadedJson;
  }

  setBookmarkItem(final jsonResponse, int index) {
    bookMarkItem.title = jsonResponse['articles'][index]['title'];
    bookMarkItem.description =
        jsonResponse['articles'][index]['description'] ??= "";
    bookMarkItem.imageURL = jsonResponse['articles'][index]['urlToImage'];
    bookMarkItem.source = jsonResponse['articles'][index]['source']['name'];
    bookMarkItem.articleURL = jsonResponse['articles'][index]['url'];
  }
}

class MyHome extends StatefulWidget {
  @override
  MyHomeState createState() => MyHomeState();
}

class BookMarks extends StatefulWidget {
  @override
  BookMarkState createState() => BookMarkState();
}

class BookMarkState extends State<BookMarks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bookmarks"),
        centerTitle: true,
        actions: <Widget>[
          StreamBuilder(
            stream: FirebaseAuth.instance.currentUser().asStream(),
            builder:
                (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(96.0),
                      boxShadow: [
                        new BoxShadow(
                            color: Colors.black54,
                            blurRadius: 0.75,
                            offset: Offset(0.0, 1.0))
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(96.0),
                      child: Image.network(snapshot.data.photoUrl),
                    ),
                  ),
                );
              } else {
                return Container(
                  height: 0.0,
                  width: 0.0,
                );
              }
            },
          )
        ]
      ),
      body: Center(
        child: FutureBuilder(
          future: _getUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              FirebaseUser user = snapshot.data;
              return FirebaseAnimatedList(
                  query: FirebaseDatabase.instance
                      .reference()
                      .child('users/' + user.uid),
                  itemBuilder: (context, snapshot, animation, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 12.0, bottom: 0.0),
                      child: GestureDetector(
                        onTap: () {
                          _launchURL(snapshot.value['articleURL']);
                        },
                        child: NewsCard(
                            child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(children: <Widget>[
                            Flexible(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          snapshot.value['source'],
                                          style:
                                            TextStyle(fontSize: 13.0, color: Colors.grey[700]),
                                        ),
                                        new PopupMenuButton<int>(
                                          icon: Icon(
                                            Icons.more_vert,
                                            size: 20.0,
                                            color: Colors.grey[700],
                                          ),
                                          padding: EdgeInsets.zero,
                                          onSelected: (_) {
                                            switch (_) {
                                              case 0:
                                                removeBookMark(FirebaseDatabase
                                                    .instance
                                                    .reference()
                                                    .child('users/' + user.uid)
                                                    .child('/' + snapshot.key));
                                                break;
                                              case 1:
                                                print("Todo");
                                                break;
                                            }
                                          },
                                          itemBuilder: (BuildContext context) =>
                                              <PopupMenuEntry<int>>[
                                                PopupMenuItem<int>(
                                                  value: 0,
                                                  child: Row(
                                                    children: <Widget>[
                                                      Icon(Icons.bookmark),
                                                      Text("  Remove Bookmark")
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
                                              ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Flexible(
                                          child: CardText(
                                        title: snapshot.value['title'],
                                        body: snapshot.value['description'],
                                      )),
                                      ImageContainer(
                                        url: snapshot.value['imageURL'],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        )),
                      ),
                    );
                  });
            }
            return new Center(
                child: CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Colors.blue)));
          },
        ),
      ),
    );
  }
}

void removeBookMark(DatabaseReference ref) async {
  ref.remove();
}

Future<FirebaseUser> _getUser() async {
  return await FirebaseAuth.instance.currentUser();
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
