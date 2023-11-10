import 'package:Jatayu/ChatPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:Jatayu/ChatPage1.dart';

class AttendanceRecordScreen extends StatefulWidget {
  const AttendanceRecordScreen({Key? key}) : super(key: key);

  @override
  _AttendanceRecordScreenState createState() => _AttendanceRecordScreenState();
}

class _AttendanceRecordScreenState extends State<AttendanceRecordScreen> {
  late DateTime selectedDate;
  late String uid;
  int chatid=0;
  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(selectedDate.year),
      lastDate: DateTime(selectedDate.year, 12, 31),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<DocumentReference> _getAttendanceDocument(DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return FirebaseFirestore.instance.collection('attendance').doc(
        formattedDate);
  }

  Future<Map<String, dynamic>?> _getAttendanceData(DateTime date) async {
    final DocumentReference attendanceDoc = await _getAttendanceDocument(date);
    final DocumentSnapshot attendanceSnapshot = await attendanceDoc.get();
    return attendanceSnapshot.data() as Map<String, dynamic>?;
  }

  Future<void> _checkIn() async {
    final DateTime now = DateTime.now();
    final String formattedTime = DateFormat('HH:mm:ss').format(now);
    final DocumentReference attendanceDoc = await _getAttendanceDocument(now);
    attendanceDoc.get().then((docSnapshot) async {
      if (!docSnapshot.exists) {
// Create a new attendance document for the day
        await attendanceDoc.set({
          uid: {
            'checkInTime': formattedTime,
            'checkOutTime': null,
          }
        });
      } else {
// Update existing attendance document with check-in time
        final Map<String, dynamic> attendanceData = docSnapshot.data() as Map<
            String,
            dynamic>;
        if (attendanceData.containsKey(uid)) {
// User has already checked-in for the day, don't do anything
          return;
        }
        attendanceData[uid] = {
          'checkInTime': formattedTime,
          'checkOutTime': null,
        };
        await attendanceDoc.update(attendanceData);
      }
    });
  }

  Future<void> _checkOut() async {
    final DateTime now = DateTime.now();
    final String formattedTime = DateFormat('HH:mm:ss').format(now);
    final DocumentReference attendanceDoc = await _getAttendanceDocument(now);
    attendanceDoc.get().then((docSnapshot) async {
      if (!docSnapshot.exists) {
// User hasn't checked-in for the day, can't check-out
        return;
      }
      final Map<String, dynamic> attendanceData = docSnapshot.data() as Map<
          String,
          dynamic>;
      if (!attendanceData.containsKey(uid)) {
// User hasn't checked-in for the day, can't check-out
        return;
      }
      attendanceData[uid]['checkOutTime'] = formattedTime;
      await attendanceDoc.update(attendanceData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Records   '+ "("+formattedDate+")"),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[900]!, Colors.blueGrey[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('attendence').doc(formattedDate).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.hasData && snapshot.data!.exists) {
              Map<String, dynamic> attendanceData = snapshot.data!.data() as Map<String, dynamic>;
              return ListView.builder(
                itemCount: attendanceData.length,
                itemBuilder: (BuildContext context, int index) {
                  String userId = attendanceData.keys.elementAt(index);
                  String? checkInTime = attendanceData[userId]['checkInTime'];
                  String? checkOutTime = attendanceData[userId]['checkOutTime'];
                  String name = attendanceData[userId]['name'];
                  String photoUrl = attendanceData[userId]['photoUrl']; // replace with actual URL to user photo

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.025, vertical: MediaQuery.of(context).size.height * 0.01),
                    height: MediaQuery.of(context).size.height * 0.18,
                    width: MediaQuery.of(context).size.width * 0.95,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.12,
                          width: MediaQuery.of(context).size.width * 0.28,
                          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              bottomLeft: Radius.circular(15.0),
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(photoUrl),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                Column(
                                  children: [
                                    Text(
                                      'Check-in time: ${checkInTime ?? 'N/A'}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                      ),
                                      textAlign: TextAlign.left,

                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                                    Text(
                                      'Check-out time: ${checkOutTime ?? 'N/A'}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );


                },
              );


            } else {
              return Center(
                child: Text('No attendance record found for $formattedDate.'),
              );
            }
          },
        ),
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Enter ChatID"),
                content: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    chatid = int.parse(value); // Store the user input as an integer in j
                  },
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      if(chatid==9953) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatPage()),
                        );
                      }
                      else if(chatid==1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatPage1()),
                        );
                      }
                      else{
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              );
            },
          );

        },

        backgroundColor: Colors.blueGrey[900],
        child: Icon(Icons.chat),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.blueGrey[900],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            IconButton(
              icon: Icon(Icons.date_range),
              onPressed: () => _selectDate(context),
              iconSize: 40,


              color: Colors.white,
            ),
          ],
        ),
      ),

    );
  }
}