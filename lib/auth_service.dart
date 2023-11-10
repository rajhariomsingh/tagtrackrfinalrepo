import 'package:Jatayu/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:Jatayu/login_page.dart';
import 'package:Jatayu/welcome_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'login_page.dart';

class AuthService{
  handleAuthState() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            createUserDocInFirestore();
            return WelcomePage();
          } else {
            return const LoginPage();
          }
        });
  }

  signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: <String>["email"]).signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);


  }
   createUserDocInFirestore() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.email);
      await userDocRef.set({
        "email": currentUser.email,
        "name": currentUser.displayName ?? "",
        "photoUrl": currentUser.photoURL ?? "",
        "status":"online",
      });
    }
  }

  signOut() async{
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();


  }
}