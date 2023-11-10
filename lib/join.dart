import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share/share.dart';

class Join extends StatefulWidget {
  const Join({Key? key}) : super(key: key);

  @override
  State<Join> createState() => _CreateState();

}


class _CreateState extends State<Join> {
  StreamSubscription<Position>? _positionStream;

  Position? _position;
  @override

  void initState() {
    super.initState();
    _getCurrentLocation();
    startLocationUpdates();
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

  StreamSubscription<Position>? locationSubscription;

  void startLocationUpdates() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      locationSubscription ??=
          Geolocator.getPositionStream().listen((position) async {
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


  @override
  void dispose() {
    super.dispose();
    _positionStream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    final mapController = MapController();


    return Scaffold(

      body: Column(

        children: [

          RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                  child: Padding(
                    padding: EdgeInsets.only(right: w * 0.03),
                    child: ImageIcon(
                      AssetImage("img/locpin.png"),
                      size: w * 0.06,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                TextSpan(
                  text: FirebaseAuth.instance.currentUser!.displayName! +
                      " This is Joining page",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: w * 0.05),
          Container(
            child: Text(
              FirebaseAuth.instance.currentUser!.email!,
              style: TextStyle(
                fontSize: w * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: w * 0.04),
          Container(
            width: w * 0.5,
            height: h * 0.07,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0072ff),
                  Color(0xFF00c6ff),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: GestureDetector(
              onTap: () {
                Share.share(FirebaseAuth.instance.currentUser!.email!);
              },
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "JOIN",
                      style: TextStyle(
                        fontSize: w * 0.08,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: w * 0.02),
                    ImageIcon(
                      AssetImage("img/locpin.png"),
                      size: w * 0.05,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: w * 0.02),

          Expanded(

            child: FlutterMap(
              options: MapOptions(
                center: LatLng(_position!.latitude,_position!.longitude),
                zoom: 15.9,
              ),
              nonRotatedChildren: [
                AttributionWidget.defaultWidget(
                  source: 'OpenStreetMap contributors',
                  onSourceTapped: null,
                ),
              ],
              children: [
                TileLayer(
                    urlTemplate: 'https://api.mapbox.com/styles/v1/hariomsinghraj/clg54anum000h01qx4521uoyk/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiaGFyaW9tc2luZ2hyYWoiLCJhIjoiY2xmdGF4cWtlMGVoZzNqbDJic3lqYjNtZiJ9.jgKZjfUi9fhryc2jxHadwA',
                    userAgentPackageName: 'com.example.app',
                    additionalOptions: {
                      'accessToken': 'pk.eyJ1IjoiaGFyaW9tc2luZ2hyYWoiLCJhIjoiY2xmdGF4cWtlMGVoZzNqbDJic3lqYjNtZiJ9.jgKZjfUi9fhryc2jxHadwA',
                      'id': 'mapbox.mapbox-streets-v8',
                    }
                ),


                MarkerLayer(  markers: [
                  Marker(
                    width: 30.0,
                    height: 30.0,
                    point:  LatLng(_position?.latitude??28.675854056843423,_position?.longitude?? 77.48024887822632),
                    builder: (ctx) =>Container(
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!),
                      ),
                    ),
                  ),
                ],)


              ],
            ),

          ),

          SizedBox(height:h*0.001),
        ],
      ),
    );
  }
}
