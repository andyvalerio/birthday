import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  Status status = Status.not_ready;
  String userId = '';

  Auth._privateConstructor();

  static final Auth _instance = Auth._privateConstructor();

  static Auth get instance => _instance;

  initAuth() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User user) {
      _authChange(user);
    });
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  _authChange(User user) {
    if (user == null) {
      userId = '';
      status = Status.signed_out;
    } else {
      userId = user.uid;
      status = Status.signed_in;
    }
  }
}

enum Status { not_ready, signed_in, signed_out }
