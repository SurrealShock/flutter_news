import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_news/navigation/widgets.dart';
import 'package:flutter_news/utilities/api.dart';
import 'package:flutter_news/utilities/bookMarkItem.dart';
import 'package:flutter_news/utilities/fetch.dart';
import 'package:flutter_news/utilities/url_launch.dart';

class Search extends StatefulWidget {
  SearchState createState() => SearchState();
}

enum FetchStatus { idle, fetching, fetched }

class SearchState extends State<Search> with SingleTickerProviderStateMixin {
  FetchStatus fetchStatus = FetchStatus.idle;
  TextEditingController textController;
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: TextField(
              onSubmitted: (value) {
                setState(() {
                  fetchStatus = FetchStatus.fetching;
                  handleSearch(value);
                });
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
              FocusScope.of(context).requestFocus(new FocusNode());
              setState(() {
                fetchStatus = FetchStatus.fetching;
                handleSearch(textController.text);
              });
            },
            icon: Icon(Icons.search),
          )
        ],
      ),
      body: SearchScreen(),
    );
  }

  Future<dynamic> handleSearch(final search) async {
    var query;
    if (search == TextEditingValue) {
      query = search.text;
    } else {
      query = search;
    }
        print('got here');

    var fetch = await fetchUrl.fetch(
        'https://newsapi.org/v2/everything?q=' + query + '&sortBy=popularity&apiKey=' + apiKey);
        print('got here');
    setState(() {
      fetchStatus = FetchStatus.fetched;
    });
    return fetch;
  }

  Widget SearchScreen() {
    switch (fetchStatus) {
      case FetchStatus.idle:
        return Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: ListView.builder(
            // padding: EdgeInsets.only(top: 4.0, bottom: 0.0),
            itemCount: popularSearches.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  textController.text = popularSearches[index];
                  setState(() {
                    fetchStatus = FetchStatus.fetching;
                  });
                  handleSearch(popularSearches[index]);
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child:
                      Text(popularSearches[index], textAlign: TextAlign.center),
                ),
              );
            },
          ),
        );
        break;
      case FetchStatus.fetching:
        return ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return LoadingCard();
            });
        break;
      case FetchStatus.fetched:
        List<BookMarkItem> bookMarkItem = [];
        return ListView.builder(
          itemCount: fetchUrl.fetchSaved()['totalResults'],
          itemBuilder: (context, index) {
            bookMarkItem.add(BookMarkItem
                .fromJson(fetchUrl.fetchSaved()['articles'][index]));
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
                          bookMarkItem[index],
                          PopupMenuButton<int>(
                            icon: Icon(
                              Icons.more_vert,
                              size: 20.0,
                              color: Colors.grey[700],
                            ),
                            padding: EdgeInsets.zero,
                            onSelected: (_) {
                              // switch (_) {
                              //   case 0:
                              //     if (!data.containsKey(
                              //         bookMarkItem[index].title)) {
                              //       bookMark(bookMarkItem[index]);
                              //     } else {
                              //       BookMarkItem.removeBookMark(
                              //           FirebaseDatabase.instance
                              //               .reference()
                              //               .child('users/' + user.uid)
                              //               .child('/' +
                              //                   data[bookMarkItem[index]
                              //                       .title]));
                              //     }
                              //     break;
                              //   case 1:
                              //     break;
                              // }
                            },
                            itemBuilder: (BuildContext context) {
                              // bool bookmarked = data
                              //     .containsKey(bookMarkItem[index].title);
                              return <PopupMenuEntry<int>>[
                                PopupMenuItem<int>(
                                  value: 0,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(true
                                          ? Icons.bookmark
                                          : Icons.bookmark_border),
                                      Text(true
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
            );
          },
        );
        break;
    }
  }
}
