
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';

import 'ImageViewer.dart';


class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late CollectionReference _messagesCollection;

  @override
  void initState() {
    super.initState();

    _messagesCollection = FirebaseFirestore.instance.collection('messages');

  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  File? _imageFile;

  void _sendMessage() async {
    String messageText = _messageController.text.trim();

    if (messageText.isNotEmpty) {
      String userName = FirebaseAuth.instance.currentUser!.displayName ?? '';
      String userId = FirebaseAuth.instance.currentUser!.uid;

      await _messagesCollection.add({
        'sender': userName,
        'text': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
      });

      _messageController.clear();
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else if (_imageFile != null) {
      // Upload image to Firebase Storage
      String fileName = basename(_imageFile!.path);
      Reference storageReference = FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = storageReference.putFile(_imageFile!);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      String userName = FirebaseAuth.instance.currentUser!.displayName ?? '';
      String userId = FirebaseAuth.instance.currentUser!.uid;

      await _messagesCollection.add({
        'sender': userName,
        'imageUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
      });

      _imageFile = null;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.blueGrey[700],
      appBar: AppBar(
        title: Text('Chat Room'),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _messagesCollection.orderBy('timestamp').snapshots(),
                    builder: (context, snapshot) {
                      try {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Something went wrong'),
                          );
                        }

                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        List<QueryDocumentSnapshot> messages = snapshot.data!.docs;

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                        });

                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic>? data = messages[index].data() as Map<String, dynamic>?;

                            if (data == null) {
                              return SizedBox.shrink();
                            }

                            bool isSentByCurrentUser = data['userId'] == FirebaseAuth.instance.currentUser!.uid;
                            String senderName = data['sender'] ?? '';
                            String messageText = data['text'] ?? '';
                            String imageUrl = data['imageUrl'] ?? '';

                            return Align(
                              alignment: isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.01),
                                padding: EdgeInsets.all(screenWidth * 0.03),
                                decoration: BoxDecoration(
                                  color: isSentByCurrentUser ? Colors.blueGrey[900] : Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      senderName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    if (imageUrl != null &&imageUrl!="")
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ImageViewer(imageUrl: imageUrl),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          height: screenHeight * 0.3,
                                          width: screenWidth * 0.5,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(screenWidth * 0.05),
                                            image: DecorationImage(
                                              image: NetworkImage(imageUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                     if(messageText.isNotEmpty&&messageText!="")
                                      Text(
                                        messageText,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          color: Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );



                      } catch (e) {
                        return SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {

                      setState(() {

                        _imageFile = File(pickedFile.path);

                      });
                      _sendMessage();
                    }
                  },
                  child: Container(
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.08,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.attach_file,
                      size: screenWidth * 0.05,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      filled: true,
                      fillColor: Colors.white60,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.1),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Icon(
                    Icons.send,
                    size: screenWidth * 0.08,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );}
    }
