import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_news/navigation/widgets.dart';
import 'package:flutter_news/utilities/fetch.dart';

class Search extends StatefulWidget {
  SearchState createState() => SearchState();
}

class SearchState extends State<Search> with SingleTickerProviderStateMixin {
  TextEditingController textController;
  AnimationController searchIconController;
  double borderWidth = 1.0;
  List<String> popularSearches = [];
  GetFromUrl fetchUrl = GetFromUrl();

  @override
  void initState() {
    popularSearches = [
      'Tech',
      'Politics',
      'Software',
      'Hardware',
      'Sports',
      'Drama',
      'Business'
    ];
    textController = TextEditingController();
    searchIconController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Animation width = Tween(
      begin: 0.0,
      end: MediaQuery.of(context).size.width,
    ).animate(searchIconController)
      ..addListener(() {
        setState(() {});
      });
    Future.delayed(Duration(milliseconds: 200)).then((_) {
      searchIconController.forward();
    });
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: width.value,
            child: TextField(
              onSubmitted: (value) {
                handleSearch(value);
              },
              onChanged: (value) {
                if (value == "") {
                  setState(() {
                    borderWidth = 1.0;
                  });
                } else {
                  setState(() {
                    borderWidth = 0.5;
                  });
                }
              },
              controller: textController,
              enabled: true,
              style: TextStyle(color: Colors.white, fontSize: 16.0),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(bottom: 2.0),
                border: InputBorder.none,
                hintText: 'Search for an article',
                hintStyle: TextStyle(color: Colors.white70),
              ),
            ),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: borderWidth,
                        color: Colors.white,
                        style: BorderStyle.solid))),
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              handleSearch(textController.value);
            },
            icon: Icon(Icons.search),
          )
        ],
      ),
      body: Recommendations(popularSearches),
    );
  }

  void handleSearch(final search) async {
    var query;
    if(search == TextEditingValue) {
      query = search.text;
    } else {
      query = search;
    }


  }
}
