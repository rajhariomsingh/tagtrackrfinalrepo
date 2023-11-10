import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:Jatayu/Signup_page.dart';
import 'package:Jatayu/auth_service.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: Column(
        children: [
          Container(
            width: w,
            height: h*0.3,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "img/jatayu3.png"
                ),
                  fit:  BoxFit.cover
              )
            ),

          ),

          Container(
            margin: const EdgeInsets.only(left: 20,right: 20),
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
                SizedBox(height: h*0.07,),

                Container(
                  height: h * 0.2,
                  width: w * 0.5,
                  child: Image.asset(
                    'img/g.png',
                    fit: BoxFit.contain,
                  ),
                  alignment: Alignment.center,
                )
                ,






              ],
            ),
          ),
          SizedBox(height: w*0.08,),
          Container(
            width: w*0.6,
            height: h*0.09,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
                color: Colors.blueGrey[700],

            ),

            child: Center(
              child: TextButton(

                  onPressed: (){
                    AuthService().signInWithGoogle();

                    // AuthService().handleAuthState();

                  },


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
