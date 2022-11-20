// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:instgram/models/message.dart';
import 'package:instgram/models/user.dart';
import 'package:instgram/providers/user_provider.dart';
import 'package:instgram/resources/firestore_methods.dart';
import 'package:instgram/screens/audio_screen.dart';
import 'package:instgram/screens/video_screen.dart';
import 'package:instgram/utils/colors.dart';
import 'package:instgram/utils/utils.dart';
import 'package:instgram/widgets/text_message.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatelessWidget {
  final UserModel user;
  ChatScreen({super.key, required this.user});

  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AudioScreen(
                  photoUrl: user.photoUrl,
                  uId: user.uid,
                  caller: true,
                ),
              ));
            },
            icon: const Icon(
              Icons.call_outlined,
              color: primaryColor,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => VideoScreen(
                  uId: user.uid,
                  caller: true,
                ),
              ));
            },
            icon: const Icon(
              Icons.videocam_outlined,
              color: primaryColor,
            ),
          )
        ],
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(user.photoUrl),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              user.username,
              style: const TextStyle(
                  color: primaryColor, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('chats')
                  .doc(user.uid)
                  .collection('messages')
                  .orderBy('datePublished')
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  return ListView.builder(
                    padding: EdgeInsets.all(18),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (ctx, index) => TextMessage(
                      message:
                          Message.fromJson(snapshot.data!.docs[index].data()),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 12),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 70, 67, 67),
                borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  minLines: 1,
                  controller: _controller,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Message...',
                      hintStyle: TextStyle(fontSize: 18),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                )),
                IconButton(
                    onPressed: () {
                      final text = _controller.text.trim();
                      _controller.clear();
                      FireStoreMethods().sendMessage(text, user.uid);
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.blue,
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }

//   void sendMessage(
//     String text,
//     String uid,
//   ) async {
//     try {
//       String res = await FireStoreMethods().sendMessage(
// text,uid
//       );
//       if (res == 'success') {
//         showSnackBar('Posted Successfully', context);

//       } else {
//         showSnackBar(res, context);

//       }
//     } catch (e) {
//       showSnackBar(e.toString(), context);

//     }
//   }
}
