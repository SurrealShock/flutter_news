import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

class Auth {
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseUser firebaseUser;
  Auth(FirebaseUser user) {
    this.firebaseUser = user;
  }

  static Future<Auth> authWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final FirebaseUser user = await firebaseAuth.signInWithGoogle(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    assert(user.email != null);
    assert(user.displayName != null);

    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await firebaseAuth.currentUser();
    assert(user.uid == currentUser.uid);

    return Auth(user);
  }

  static void signOutFirebase() async {
    await firebaseAuth.signOut();
  }

  static Future<FirebaseUser> getUser() async {
    return await firebaseAuth.currentUser();
  }
}
