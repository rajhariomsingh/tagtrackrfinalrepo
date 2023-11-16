import 'package:Jatayu/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Jatayu/welcome_page.dart';

import 'auth_service.dart';
// Import the login screen file

class CompanyValidationPage extends StatefulWidget {
  @override
  _CompanyValidationPageState createState() => _CompanyValidationPageState();
}

class _CompanyValidationPageState extends State<CompanyValidationPage> {
  final TextEditingController _companyIdController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "img/jatayu2.jpg",
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _companyIdController,
                        decoration: InputDecoration(
                          hintText: 'Company ID',
                        ),
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () => _validateCompany(context),
                        child: Text('Enter'),
                      ),
                      SizedBox(height: 16.0),
                      InkWell(
                        onTap: () async {
                          await AuthService().signOut();
                          // Navigate back to the main entry point after sign-out
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        child: Text('Back to Login'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validateCompany(BuildContext context) async {
    String companyId = _companyIdController.text.trim();
    String userEmail =
        _auth.currentUser?.email ?? ''; // Get the current user's email

    if (companyId.isNotEmpty) {
      var companySnapshot =
          await _firestore.collection('companies').doc(companyId).get();

      if (companySnapshot.exists) {
        // Check if the user's email exists in the company's employee array
        List<String> employees =
            List<String>.from(companySnapshot.data()?['employee'] ?? []);

        if (employees.contains(userEmail)) {
          await createUserDocInFirestore();
          // User is registered with the company, navigate to WelcomePage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WelcomePage()),
          );
        } else {
          _showErrorDialog('User not registered by the company.');
        }
      } else {
        _showErrorDialog('Company not found or not registered.');
      }
    } else {
      _showErrorDialog('Please enter a valid Company ID.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  createUserDocInFirestore() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection("users").doc(currentUser.email);
      await userDocRef.set({
        "email": currentUser.email,
        "name": currentUser.displayName ?? "",
        "photoUrl": currentUser.photoURL ?? "",
        "status": "online",
        "company": _companyIdController.text.trim(),
        "uid": currentUser.uid,
      });
    }
  }
}
