import 'dart:async';
import 'firebase.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<bool> logIn() async {
      final user = await Auth.authWithGoogle();
      if (user != null) {
        return true;
      } else {
        return false;
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Sign In'),
        ),
        body: Center(
          child: InkWell(
            onTap: () async {
              bool signedIn = await logIn();
              print(signedIn);
              signedIn
                  ? Navigator.of(context).pushNamed('news')
                  : showDialog(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context) {
                        return new AlertDialog(
                          title: new Text('Invalid Login'),
                          content: new SingleChildScrollView(
                            child: new ListBody(
                              // This text from the AlrtDialog sample I swear I didn't put this here
                              // Will fix later
                              children: <Widget>[
                                new Text('something something'),
                                new Text(
                                    'still need to test this'),
                              ],
                            ),
                          ),
                        );
                      },
                    );
            },
            child: Image.asset("images/google_signin.png", height: 46.0),
          ),
        ),
      ),
    );
  }
}
