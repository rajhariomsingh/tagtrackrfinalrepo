import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:ndef/ndef.dart' as ndef;

import 'attendencerecordscreen.dart';
import 'package:permission_handler/permission_handler.dart';


class NfcImplement extends StatefulWidget {
  const NfcImplement({Key? key}) : super(key: key);

  @override
  _NfcImplementState createState() => _NfcImplementState();
}

class _NfcImplementState extends State<NfcImplement> {
  StreamSubscription<NfcTag>? _streamSubscription;
  String? _message;
  String? _key;
  String verify = 'Hogya bhai hogya';
  bool _hasCheckedIn = false;

  @override
  void initState() {
    super.initState();

    _startNfcListening();
  }

  @override
  void dispose() {
    _stopNfcListening();
    super.dispose();
  }
  bool _showNfcMessage = true;


  void _hideNfcMessage() {
    setState(() {
      _showNfcMessage = false;
    });
  }


  Future<void> requestBackgroundLocationPermission() async {
    final status = await Permission.locationAlways.request();
    if (status == PermissionStatus.denied) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Location permission denied'),
          content: Text('Please grant location permission in the app settings to use this feature.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }else if (status == PermissionStatus.granted) {
      _hasCheckedIn =true;
    }
  }

  void _startNfcListening() async{
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          Ndef? ndef = Ndef.from(tag);
          if (ndef == null) {
            return;
          }
          NdefMessage message = await ndef.read();
          String payload = utf8.decode(message.records[0].payload);
          payload = payload.substring(4); // remove first 2 characters
          setState(() {
            _message = payload;
            _key = payload;

          });

          if (_message == verify) {
            await requestBackgroundLocationPermission();
            if(_hasCheckedIn==true){
            String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
            String uid = FirebaseAuth.instance.currentUser!.uid;
            DocumentReference attendanceRef = FirebaseFirestore.instance.collection('attendence').doc(currentDate);
            attendanceRef.get().then((docSnapshot) {
              if (docSnapshot.exists) {
                Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
                if (data != null && data[uid] != null) {
                  // User has already checked-in, record check-out time
                  data[uid] = {
                    'checkInTime': data[uid]['checkInTime'],
                    'checkOutTime': DateFormat('HH:mm:ss').format(DateTime.now()),
                    'name':FirebaseAuth.instance.currentUser!.displayName!,
                    'photoUrl':FirebaseAuth.instance.currentUser!.photoURL!,
                    'email':FirebaseAuth.instance.currentUser!.email,
                  };

                } else {
                  // User has not checked-in yet, record check-in time
                  data ??= {};
                  data[uid] = {
                    'checkInTime': DateFormat('HH:mm:ss').format(DateTime.now()),
                    'checkOutTime': 'nil',
                    'name':FirebaseAuth.instance.currentUser!.displayName!,
                    'photoUrl':FirebaseAuth.instance.currentUser!.photoURL!,
                    'email':FirebaseAuth.instance.currentUser!.email,
                  };
                }
                attendanceRef.set(data, SetOptions(merge: true)).then((value) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => AttendanceRecordScreen()));
                });
              } else {
                // User has not checked-in yet, record check-in time
                Map<String, dynamic> data = {
                  uid: {
                    'checkInTime': DateFormat('HH:mm:ss').format(DateTime.now()),
                    'checkOutTime': 'nil',
                    'name':FirebaseAuth.instance.currentUser!.displayName!,
                    'photoUrl':FirebaseAuth.instance.currentUser!.photoURL!,
                    'email':FirebaseAuth.instance.currentUser!.email,
                  },
                };
                attendanceRef.set(data).then((value) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => AttendanceRecordScreen()));
                });
              }
            });
          }}
        } catch (e) {
          print(e);
        }
      },
    ).then((_) {
      setState(() {});
    });
  }


  void _stopNfcListening() {
    _streamSubscription?.cancel();
  }


  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC Record Management'),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: Container(
        height: h * 1,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[900]!, Colors.blueGrey[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: w * 0.1, vertical: h * 0.05),
            height: h * 0.4,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'img/jatayu3.png',
                  height: h*0.26,
                  width: w*0.9,
                ),
                SizedBox(height: h * 0.00001),
                Text(
                  _message ?? 'Hold your device near NFC tag.',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
      // Display the pop-up message if _showNfcMessage is true
      floatingActionButton: _showNfcMessage
          ? FloatingActionButton.extended(
        onPressed: () {
          _hideNfcMessage();
        },
        label: Text('Please Turn On NFC'),
        icon: Icon(Icons.warning),
        backgroundColor: Colors.red,
      )
          : null,
    );
  }
}