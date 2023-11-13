import 'package:Jatayu/companyValidationPage.dart';
import 'package:flutter/material.dart';
import 'package:Jatayu/Signup_page.dart';
import 'package:Jatayu/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Function to handle Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    try {
      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in process
        return;
      }

      // Obtain the GoogleSignInAuthentication object
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential using the GoogleSignInAuthentication object
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credentials
      final UserCredential authResult =
          await _auth.signInWithCredential(credential);

      // Navigate to the company validation page after successful sign-in
      // Replace 'CompanyValidationPage()' with the actual destination widget
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CompanyValidationPage()),
      );
    } catch (e) {
      print('Google Sign-In Error: $e');
      // Handle sign-in error
    }
  }

  double w = 0;
  double h = 0;

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Column(
        children: [
          Container(
            width: w,
            height: h * 0.3,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("img/jatayu3.png"), fit: BoxFit.cover)),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                Text(
                  "Namaste",
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Please Log In Using",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white60,
                  ),
                ),
                SizedBox(
                  height: h * 0.07,
                ),
                Container(
                  height: h * 0.2,
                  width: w * 0.5,
                  child: Image.asset(
                    'img/g.png',
                    fit: BoxFit.contain,
                  ),
                  alignment: Alignment.center,
                ),
              ],
            ),
          ),
          SizedBox(
            height: w * 0.08,
          ),
          Container(
            width: w * 0.6,
            height: h * 0.09,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.blueGrey[700],
            ),
            child: Center(
              child: TextButton(
                onPressed: _handleGoogleSignIn, // Call Google Sign-In method
                child: Text(
                  "Sign In",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
