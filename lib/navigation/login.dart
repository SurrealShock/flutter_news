import 'dart:async';
import 'package:flutter_news/navigation/bottom_nav.dart';
import 'package:flutter_news/utilities/firebase.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> with SingleTickerProviderStateMixin {
  AnimationController _buttonWidthController;
  Animation _width;
  @override
  void initState() {
    _buttonWidthController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    _width = Tween(
      begin: 150.0,
      end: 60.0,
    ).animate(_buttonWidthController)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _buttonWidthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> logIn() async {
      try {
        _buttonWidthController.forward();
      } on TickerCanceled {}
      final user = await Auth.authWithGoogle();

      if (user != null) {
        return true;
      } else {
        return false;
      }
    }

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: GestureDetector(
            onTap: () async {
              bool signedIn = await logIn();
              signedIn
                  ? Navigator
                      .of(context)
                      .push(MaterialPageRoute(builder: (context) => News()))
                  : showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Invalid Login'),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Text('Please try signing in again.'),
                                Text('An unknown error occured.'),
                              ],
                            ),
                          ),
                        );
                      },
                    );
            },
            child: Container(
              alignment: Alignment.center,
              height: 60.0,
              width: _width.value,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(30.0)),
              child: _width.value > 95
                  ? Text(
                      'Sign in with Google',
                      style: TextStyle(fontSize: 17.0, color: Colors.white),
                    )
                  : CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
