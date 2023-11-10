import 'dart:async';

import 'package:Jatayu/attendencerecordscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Jatayu/Create.dart';
import 'package:Jatayu/NfcImplement.dart';
import 'package:Jatayu/UserProfilePage.dart';
import 'package:Jatayu/auth_service.dart';


import 'package:geolocator/geolocator.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:background_fetch/background_fetch.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  StreamSubscription<Position>? _positionStream;
  Position? _position;
  bool _isInBackground = false;

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();
    startLocationUpdates();
    _initBackgroundFetch();
  }

  @override
  void dispose() {
    super.dispose();
    _positionStream?.cancel();
  }

  void startLocationUpdates() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _positionStream = Geolocator.getPositionStream().listen((position) async {

        final collection = FirebaseFirestore.instance.collection(
            'user_locations');
        await collection.doc(user.email).update({
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
        setState(() {
          _position = position;
        });
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final currentPosition = await Geolocator.getCurrentPosition();
      final collection = FirebaseFirestore.instance.collection(
          'user_locations');
      await collection.doc(user.email).set({
        'latitude': currentPosition.latitude,
        'longitude': currentPosition.longitude,
        'photoUrl': user.photoURL,
      });
      setState(() {
        _position = currentPosition;
      });
    }
  }

  Future<void> _initBackgroundFetch() async {
    // Register the background fetch task with a unique task ID
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 0.001.toInt(), // Fetch interval in minutes
            stopOnTerminate: false, // Continue running after app is terminated
            enableHeadless: true, // Run task in headless mode
            requiresBatteryNotLow: false, // Don't require low battery mode
            requiresCharging: false, // Don't require charging
            requiresStorageNotLow: false, // Don't require low storage
            requiresDeviceIdle: false),

        // Don't require idle device
        _onBackgroundFetch)
        .then((int status) {
      print('[BackgroundFetch] configure success: $status');
      // Set the task to complete when the app is resumed
      BackgroundFetch.finish(status.toString());
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });
  }

  void _onBackgroundFetch() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _isInBackground) {
      final currentPosition = await Geolocator.getCurrentPosition();
      final collection = FirebaseFirestore.instance.collection(
          'user_locations');
      await collection.doc(user.email).update({
        'latitude': currentPosition.latitude,
        'longitude': currentPosition.longitude,
      });
      print(
          '[BackgroundFetch] location update success: ${currentPosition.latitude}, ${currentPosition.longitude}');
    }
    // Set the task to complete when finished
    BackgroundFetch.finish(
        BackgroundFetch.FETCH_RESULT_NEW_DATA.toString());
  }
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        startLocationUpdates();
        break;
      case AppLifecycleState.paused:
           startLocationUpdates();
        break;
      default:
        break;
    }
  }
  void stopLocationUpdates() {
    _positionStream?.cancel();
    _positionStream = null;
  }
  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
     appBar: AppBar(
       backgroundColor: Colors.blueGrey[900],
       elevation: 0,
       title: Text('Welcome - ' + FirebaseAuth.instance.currentUser!.displayName!),
       actions: [
         Stack(
           children: [
             Padding(
               padding: EdgeInsets.only(right: w * 0.09),
               child: InkWell(
                 onTap: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => UserProfilePage()),
                   );
                 },
                 child: CircleAvatar(
                   backgroundColor: Colors.white,
                   child: Icon(
                     Icons.person,
                     color: Colors.black,
                   ),
                 ),
               ),
             ),
             Positioned(
               top: h * 0.034,
               right: w * 0.1,
               child: Container(),
             ),
           ],
         ),
       ],
     ),



      body:
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[900]!, Colors.blueGrey[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(

            children: [
              Container(

                width: w,
                height: h * 0.01,

              ),


              SizedBox(height: w*0.08,),


              // RichText(text: TextSpan(
              //
              //   text: FirebaseAuth.instance.currentUser!.displayName!,
              //   style: TextStyle(
              //     color: Colors.grey[500],
              //     fontSize: 17,
              //   ),
              //
              // )),


              Container(
                width: w * 0.94,
                height: h * 0.3,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: w * 0.5,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("img/jatayu3.png"),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Track    ",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Realtime track your Personnels",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Create()),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                "Start",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),




              SizedBox(height:w*0.1,),

              Container(
                width: w * 0.94,
                height: h * 0.3,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: w * 0.5,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("img/nfctag.png"),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "In/Out    ",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Click to add your record via NFC",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => NfcImplement()),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                "OPEN",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height:w*0.1,),




              Container(
                width: w * 0.94,
                height: h * 0.3,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: w * 0.5,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("img/records4.png"),

                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Your Record    ",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Watch your Records here..",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AttendanceRecordScreen()),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                "OPEN",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height:w*0.1,),

              Container(
                width: w * 0.94,
                height: h * 0.3,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: w * 0.5,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                          Center(
                            child: ClipOval(
                              child: Image.network(
                                FirebaseAuth.instance.currentUser!.photoURL!,
                                width: w * 0.4,
                                height: w * 0.4,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "LogOut    ",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            FirebaseAuth.instance.currentUser!.displayName!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                          InkWell(
                            onTap: () {
                              AuthService().signOut();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                "LogOut",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),



            ],
          ),
        ),
      ),

    );
  }
}

