import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_news/navigation/bottom_nav.dart';
import 'package:flutter_news/navigation/login.dart';
import 'package:flutter_news/utilities/firebase.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: Colors.cyan[600]
      ),
      home: FutureBuilder(
        future: getUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data ? News() : Login();
          } else {
            return Container(
              color: Colors.white,
            );
          }
        },
      ),
    );
  }

  // This is required due to the fact that when no user is signed in
  // currentUser() returns null. However, when using a FutureBuilder
  // it checks that snapshot.data is not null for snapshot.hasData
  // to be true. Without this snapshot.hasData would never be true.
  Future<bool> getUser() async {
    var user = await Auth.getUser();
    if (user == null) {
      return false;
    }
    return true;
  }
}
