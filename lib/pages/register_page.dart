import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:assignment/components/my_textfield.dart';
import 'package:assignment/components/my_button.dart';
import 'package:assignment/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  // final genderController = TextEditingController();
  // final phoneController = TextEditingController();

  void signUserUp() async {
    // Show loading indicator
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        );
      },
    );

    try {
      if (passwordController.text == confirmPasswordController.text) {
        // Create a new user in Firebase Auth
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        // Get user's unique ID
        String userId = userCredential.user!.uid;

        // Add user details to Firestore
        addUserDetails(
          userId: userId,
          fullName: fullNameController.text.trim(),
          email: emailController.text.trim(),
          // gender: genderController.text.trim(),
          // phone: phoneController.text.trim(),
        );
      } else {
        showErrorMessage("Passwords don't match!");
      }
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.code);
    }
  }

  Future addUserDetails({
    required String userId,
    required String fullName,
    required String email,
    // gender,
    // phone,
  }) async {
    // Get the default location (can be updated later)
    // const double defaultLatitude = 0.0;
    // const double defaultLongitude = 0.0;

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'fullName': fullName,
      'email': email,
      // 'gender': gender,
      // 'phone': phone,
      // 'location': {
      //   'latitude': defaultLatitude,
      //   'longitude': defaultLongitude,
      // },
    });
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // logo
              const Icon(
                Icons.app_registration,
                size: 50,
                color: Colors.black,
              ),
              const SizedBox(height: 25),

              // welcome back, you've been missed!
              Text(
                'Let\'s create an account for you!',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              // first name textfield
              MyTextField(
                controller: fullNameController,
                hintText: 'Full Name',
                obscureText: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              // password textfield
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              const SizedBox(height: 10),

              MyTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),

              const SizedBox(height: 25),

              // sign in button
              MyButton(
                text: 'Sign up',
                onTap: signUserUp,
              ),

              const SizedBox(height: 50),

              // or continue with
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // google button
              GestureDetector(
                onTap: () => AuthService()
                    .signInWithGoogle(context), // Google Sign-In function
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 60.0),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // Shadow position
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google Icon
                      Image.asset(
                        'assets/images/google.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 12), // Space between icon and text

                      // Button Text
                      const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // not a member? register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account! ',
                    style: TextStyle(color: Colors.grey[700], fontSize: 18),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Login now',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      )),
    );
  }
}
