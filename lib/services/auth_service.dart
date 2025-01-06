import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  // Private GoogleSignIn instance
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isDialogVisible = false; // Track dialog visibility
  bool _isSigningIn = false; // Prevent multiple calls

  // Sign-in with Google
  void signInWithGoogle(BuildContext context) async {
    if (_isSigningIn) {
      return; // Prevent duplicate calls
    }
    _isSigningIn = true;

    // Show loading dialog
    if (!_isDialogVisible) {
      _isDialogVisible = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          );
        },
      );

      // Automatically dismiss the dialog after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (_isDialogVisible && Navigator.canPop(context)) {
          // Check if context is still valid before dismissing
          Navigator.pop(context); // Dismiss dialog after 5 seconds
          _isDialogVisible = false;
        }
      });
    }

    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
      if (gUser == null) {
        throw Exception("Google Sign-In was canceled");
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      String userId = userCredential.user!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        await addUserDetails(
          userId: userId,
          fullName:
              userCredential.user!.displayName?.split(' ').first ?? 'No Name',
          email: userCredential.user!.email ?? 'No Email',
        );
      }
    } catch (e) {
      showErrorMessage(context, e.toString());
    } finally {
      // Ensure dialog is dismissed properly
      if (_isDialogVisible && Navigator.canPop(context)) {
        Navigator.pop(context); // Dismiss dialog after process
        _isDialogVisible = false;
      }
      _isSigningIn = false;
    }
  }

  // Add user details to Firestore
  Future<void> addUserDetails({
    required String userId,
    required String fullName,
    required String email,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'fullName': fullName,
      'email': email,
    });
  }

  // Show error message
  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
