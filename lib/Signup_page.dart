import 'package:flutter/material.dart';
import 'package:Jatayu/auth_service.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    List images=[
      "g.png",
    ];
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
                        "img/jatayu2.jpg"
                    ),
                    fit:  BoxFit.cover
                )
            ),

          ),

          Container(
            margin: const EdgeInsets.only(left: 20,right: 20),
            child: Column(
              children: [
                SizedBox(height: w*0.15,),

                Container(
                  decoration: BoxDecoration(
                      color:Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          offset: Offset(1,1),
                          color: Colors.grey.withOpacity(0.5),
                        )
                      ]
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "Your Email ID",
                        prefixIcon: Icon(Icons.email,color: Colors.black,),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.0,
                            )
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.0,
                            )
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)
                        )
                    ),
                  ),
                ),
                SizedBox(height: 20,),

                Container(
                  decoration: BoxDecoration(
                      color:Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          offset: Offset(1,1),
                          color: Colors.grey.withOpacity(0.5),
                        )
                      ]
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "Passward",
                        prefixIcon: Icon(Icons.password,color: Colors.black,),

                        focusedBorder: OutlineInputBorder(
                            borderRadius:BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.0,
                            )
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.0,
                            )
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)
                        )
                    ),
                  ),
                ),




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
              child: Text(
                "Sign UP",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

          ),
          SizedBox(height:w*0.1,),
          RichText(text: TextSpan(
              text: "Sign UP using Google",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 17,
              ),

          )),
          SizedBox(height: w*0.08,),
          Wrap(
            children: List<Widget>.generate(
                1,
                    (index){
                  return InkWell(
                    onTap: () {
                      AuthService().signInWithGoogle();
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage("img/" + images[index]),
                    ),
                  );
                    }

            ),
          )
        ],
      ),

    );
  }
}
