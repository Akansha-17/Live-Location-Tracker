import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  signInWithGoogle() async {
    GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication gAuth = await gUser!.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken, idToken: gAuth.idToken);

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    // print(userCredential.user?.displayName);
    return userCredential;
  }
}
