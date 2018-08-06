import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_news/navigation/bookmarks.dart';
import 'package:flutter_news/navigation/home.dart';

class News extends StatefulWidget {
  @override
  NewsState createState() => NewsState();
}

class NewsState extends State<News> {
  int index = 0;

  @override
  void deactivate() {
    print("pressed");
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Disallow swiping back to login screen
      onWillPop: () => Future.value(false),
      child: MaterialApp(
        home: Scaffold(
          // Create stack to load both pages/
          // Also allows data persistence when switchting between pages
          body: Stack(
            children: <Widget>[
              // When not in use don't load graphics
              Offstage(
                offstage: index != 0,
                child: TickerMode(
                  enabled: index == 0,
                  child: Home(),
                ),
              ),
              Offstage(
                offstage: index != 1,
                child: TickerMode(
                  enabled: index == 1,
                  child: BookMarks(),
                ),
              ),
            ],
          ),
          // Create bottom navbar with home and bookmarks nav
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: (index) {
              setState(() {
                this.index = index;
              });
            },
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: Text("Home"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.collections_bookmark),
                title: Text("Bookmarks"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
