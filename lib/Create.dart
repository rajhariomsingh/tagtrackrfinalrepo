import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Create extends StatefulWidget {
  const Create({Key? key}) : super(key: key);

  @override
  State<Create> createState() => _CreateState();

}

class _CreateState extends State<Create> {
  DateTime? lastAlertTime ;
  StreamSubscription<Position>? _positionStream;
  List<Marker> markers = [];
   List<String>  addedUser = [];
 int x=1;
  Position? _position;
  String userInput = '';
  String candidate='';
  double longi=0;
  double lati=0;
  double longitude=0;
  double latitude=0;
  double ?latitudec;
  double ?longitudec;
  int i=0,j=0;
  bool isFirstMarker = true;
  String? photoUrl;
  List<LatLng> polygonPoints = [];

  double getDistanceFromLatLonInKm(double lat1, double lon1, double lat2, double lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = _deg2rad(lat2 - lat1);  // deg2rad below
    var dLon = _deg2rad(lon2 - lon1);
    var a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
                sin(dLon / 2) *
                sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
  }

  double _deg2rad(deg) {
    return deg * (pi / 180);
  }



  @override
  void initState() {
    super.initState();
    printUserLocations();
    _getCurrentLocation();

    startLocationUpdates();

  }
  @override
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
        'email': user.email,
      });
      latitudec= currentPosition.latitude;
      longitudec= currentPosition.longitude;
    }
  }

  StreamSubscription<Position>? locationSubscription;
  final _textController = TextEditingController();
  @override
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
          });
    }
  }

// Retrieve all users' location data from Firestore.
  Stream<List<QueryDocumentSnapshot>> getUsersLocations() {
    final collection = FirebaseFirestore.instance.collection('user_locations');
    return collection.snapshots().map((snapshot) => snapshot.docs);
  }
  @override

  void printUserLocations() {
    final collection = FirebaseFirestore.instance.collection('user_locations');
    getUsersLocations().listen((List<QueryDocumentSnapshot> snapshot) {
      markers.clear();

      snapshot.forEach((document) async {
        if (addedUser.contains(document.id)) {
          var data = document.data() as Map<String, dynamic>?;
          double latitude = data?['latitude'];
          double longitude = data?['longitude'];
          LatLng userLocation = LatLng(latitude, longitude);

          // Get the user's photo URL
          final user = FirebaseAuth.instance.currentUser!;
          final photoUrl = data?['photoUrl'];


          // Add a new marker with the updated location data
          markers.add(Marker(
            point: userLocation,
            width: 30.0,
            height: 30.0,

            builder: (ctx) => Container(
              child: CircleAvatar(
                backgroundImage: NetworkImage(photoUrl!),
              ),
            ),


          ));
          print('User ${document.id} location: $latitude, $longitude');
        }
      });

      // Add the current user marker with a red color
    });
  }
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserDocFromEmail(String email) async {
    final userQuery = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
    if (userQuery.docs.isNotEmpty) {
      final userDocRef = userQuery.docs.first.reference;
      final userDocSnapshot = await userDocRef.get();
      return userDocSnapshot;
    }
    return null;
  }



  @override
  void dispose() {
    super.dispose();
    printUserLocations();
    locationSubscription?.cancel();
    locationSubscription = null;
    _positionStream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    final mapController = MapController();



    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking'),
        backgroundColor: Colors.blueGrey[700],
        elevation: 0,
      ),

      body: Container(
        color: Colors.blueGrey[700],
        child: Column(

          children: [


            SizedBox(height: w * 0.0001),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    offset: Offset(1, 1),
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: "Enter User",
                  prefixIcon: Icon(Icons.person, color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.lightBlueAccent,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1.0,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onChanged: (value) {
                  userInput = value;
                },
              ),
            ),
            SizedBox(height: w * 0.01),
            Container(
              width: w * 0.49,
              height: h * 0.07,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [
                    Colors.blueGrey[900]!,
                    Colors.blueGrey[700]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    offset: Offset(1, 1),
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 10,
                    top: 5,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Added Users"),
                              content: Container(
                                width: double.maxFinite,
                                height: h * 0.5, // updated height
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: addedUser.length,
                                  itemBuilder: (context, index) {
                                    String userDocId = addedUser[index];
                                    if (userDocId.isEmpty) {
                                      return Container(); // skip empty document IDs
                                    }
                                    return FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance.collection('users').doc(userDocId).get(),
                                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                        if (snapshot.connectionState == ConnectionState.done) {
                                          if (snapshot.hasData) {
                                            final name = snapshot.data!.get('name');
                                            final photoUrl = snapshot.data!.get('photoUrl');
                                            final status = snapshot.data!.get('status');
                                            final isOnline = status == 'online'; // check if status is 'online'
                                            return Row(
                                              children: [
                                                SizedBox(width: 10),
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color: isOnline ? Colors.green : Colors.red, // set color based on status
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                ),

                                                SizedBox(width: 10),
                                                CircleAvatar(
                                                  backgroundImage: NetworkImage(photoUrl!),
                                                  maxRadius: 20,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  name,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Spacer(),
                                                IconButton(
                                                  icon: Icon(Icons.remove),
                                                  onPressed: () {
                                                    setState(() {
                                                      addedUser.removeAt(index);
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          } else {
                                            return Container(); // handle error case
                                          }
                                        } else {
                                          return CircularProgressIndicator(); // handle loading state
                                        }
                                      },
                                    );
                                  },
                                ),

                              ),


                            );
                          },
                        );
                      },
                    child: Image.asset(
                      "img/locpin.png",
                      height: 40,
                      width: 40,
                    ),
                  ),
            ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        if (i == 0) {
                          addedUser.add(FirebaseAuth.instance.currentUser!.email!);
                          i++;
                        };
                        addedUser.add(userInput);
                        print(userInput);
                        _textController.clear();
                      },
                      child: Text(
                        "ADD",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 5,
                    child: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Enter radius value in Kms"),
                              content: TextField(
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  j = int.parse(value); // Store the user input as an integer in j
                                },
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: w*0.02,),
            Container(

              child: Expanded(
                child: FlutterMap(
                    options: MapOptions(
                    center: LatLng(latitudec ?? 28.675091600858153, longitudec ?? 77.50238807782577),
                     zoom: 14,
                     onPositionChanged: (MapPosition position, bool hasGesture) {
    // Check if any markers are outside the circle
                       // Create a variable to store the time of the last alert box display.




                       if (j > 0) {
                         markers.forEach((marker) {
                           if (getDistanceFromLatLonInKm(marker.point.latitude, marker.point.longitude, latitudec ?? 28.675091600858153, longitudec ?? 77.50238807782577) > j) {
                             // Check if enough time has passed since the last alert box display.
                             if (lastAlertTime == null || DateTime.now().difference(lastAlertTime!) > Duration(minutes: 30)) {
                               // Marker is outside the circle and enough time has passed since the last alert box display, show a popup.
                               showDialog(
                                 context: context,
                                 builder: (BuildContext context) {
                                   return AlertDialog(
                                     title: Text('Marker outside Area'),
                                     content: Text('A Candidate has moved outside the Marked Area.'),
                                     actions: [
                                       TextButton(
                                         onPressed: () => Navigator.pop(context),
                                         child: Text('OK'),
                                       ),
                                     ],
                                   );
                                 },
                               );
                               // Update the variable with the current time.
                               lastAlertTime = DateTime.now();
                             }
                           }
                         });
                       }


                     },
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
                 'accessToken':'pk.eyJ1IjoiaGFyaW9tc2luZ2hyYWoiLCJhIjoiY2xmdGF4cWtlMGVoZzNqbDJic3lqYjNtZiJ9.jgKZjfUi9fhryc2jxHadwA',
                  'id': 'mapbox.mapbox-streets-v8',
                 },
                 ),
                MarkerLayer(
                markers: markers,
                ),
                CircleLayer(
                 circles: [
                CircleMarker(
                point: LatLng(latitudec ?? 28.675091600858153, longitudec ?? 77.50238807782577),
                 color: Colors.red.withOpacity(0.5),
                borderStrokeWidth: 2,
                radius: j * 1000, // Convert kilometer value to meters
                useRadiusInMeter: true, // Set to true to keep circle size fixed on zoom
                ),
               ],
              ),
              ],
              ),
          ),
            ),
            SizedBox(height:h*0.001),
          ],
        ),
      ),

    );
  }
}
