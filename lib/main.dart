import 'package:flutter/material.dart';
import 'news.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  FirebaseAuth.instance.currentUser().then((data) {
    runApp(MyApp(login: data == null ? false : true,)) ;
  });
}

class MyApp extends StatelessWidget {
  final login;
  MyApp({this.login});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "news": (context) => News(),
        "login": (context) => Login(),
      },
      //TODO: Check if logged in
      home: login ? News() : Login(),
    );
  }
}
