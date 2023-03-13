import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = FirebaseFirestore.instance;
User? loggedInUser;

class ChatScreen extends StatefulWidget {
  static const id = 'Chat_Screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;

  String? messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser!;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void getMessages() async {
    _fireStore.collection("messages").get().then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          print('${docSnapshot.id} => ${docSnapshot.data()}');
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // messageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      getMessages();
                      _fireStore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser!.email,
                        'date': DateTime.now().toIso8601String().toString(),
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class messageStream extends StatelessWidget {
//   const messageStream({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _fireStore.collection('messages').orderBy('date').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           final messages = snapshot.data!.docs.reversed;
//           List<messageBubble> messageBubbles = [];

//           for (var message in messages) {
//             final messageText = message.get('text');
//             final messagesender = message.get('sender');

//             final currentuser = loggedInUser?.email;

//             messageBubbles.add(
//               messageBubble(
//                 text: messageText,
//                 sender: messagesender,
//                 isme: currentuser == messagesender,
//               ),
//             );
//           }
//           return Expanded(
//             child: ListView(
//               reverse: true,
//               padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//               children: messageBubbles,
//             ),
//           );
//         } else {
//           return Text('data not found');
//         }
//       },
//     );
//   }
// }

// class messageBubble extends StatelessWidget {
//   messageBubble({this.text, this.sender, this.isme = true});

//   String? sender;
//   String? text;
//   bool isme = true;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: Column(
//         crossAxisAlignment:
//             isme ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(
//             '$sender',
//             style: TextStyle(fontSize: 12, color: Colors.black54),
//           ),
//           Material(
//             borderRadius: isme
//                 ? BorderRadius.only(
//                     topLeft: Radius.circular(30),
//                     bottomLeft: Radius.circular(30),
//                     bottomRight: Radius.circular(30))
//                 : BorderRadius.only(
//                     topRight: Radius.circular(30),
//                     bottomLeft: Radius.circular(30),
//                     bottomRight: Radius.circular(30)),
//             elevation: 5,
//             color: isme ? Colors.lightBlueAccent : Colors.white,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//               child: Text(
//                 '$text',
//                 style: TextStyle(
//                     fontSize: 15, color: isme ? Colors.white : Colors.black54),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
