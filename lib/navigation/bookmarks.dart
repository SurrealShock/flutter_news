import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
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
  BookMarkItem bookMarkItem;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Bookmarks"), centerTitle: true, actions: <Widget>[
        StreamBuilder(
          stream: FirebaseAuth.instance.currentUser().asStream(),
          builder:
              (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
            if (snapshot.hasData) {
              return ProfilePicture(snapshot.data.photoUrl);
            } else {
              return Container(
                height: 0.0,
                width: 0.0,
              );
            }
          },
        ),
        IconButton(
          onPressed: () {
            Navigator
                .of(context)
                .push(MaterialPageRoute(builder: (context) => Search()));
          },
          icon: Icon(Icons.search),
        )
      ]),
      body: Center(
        child: FutureBuilder(
          future: Auth.getUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              FirebaseUser user = snapshot.data;
              return FirebaseAnimatedList(
                  query: FirebaseDatabase.instance
                      .reference()
                      .child('users/' + user.uid),
                  itemBuilder: (context, snapshot, animation, index) {
                    bookMarkItem = BookMarkItem.fromSnapshot(snapshot.value);
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 12.0, bottom: 0.0),
                      child: GestureDetector(
                        onTap: () {
                          launchURL(bookMarkItem.articleURL);
                        },
                        child: NewsContainer(
                            child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(children: <Widget>[
                            NewsCard(
                                bookMarkItem,
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
                                        BookMarkItem.removeBookMark(
                                            FirebaseDatabase.instance
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
                                )),
                          ]),
                        )),
                      ),
                    );
                  });
            }
            return Loading(Colors.blue);
            // return ListView.builder(
            //   itemCount: 10,
            //   itemBuilder: (context, index) {
            //     return LoadingCard(index + 5);
            //   });
          },
        ),
      ),
    );
  }
}
