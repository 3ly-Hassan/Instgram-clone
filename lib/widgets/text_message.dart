import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/message.dart';

class TextMessage extends StatelessWidget {
  final Message message;
  const TextMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.me == FirebaseAuth.instance.currentUser!.uid
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
            color: message.me == FirebaseAuth.instance.currentUser!.uid
                ? Colors.deepPurpleAccent
                : Color.fromARGB(255, 70, 67, 67),
            borderRadius: BorderRadius.only(
              topLeft: message.me == FirebaseAuth.instance.currentUser!.uid
                  ? Radius.circular(12)
                  : Radius.zero,
              topRight: message.me != FirebaseAuth.instance.currentUser!.uid
                  ? Radius.circular(12)
                  : Radius.zero,
              bottomLeft: message.me != FirebaseAuth.instance.currentUser!.uid
                  ? Radius.elliptical(20, 70)
                  : Radius.circular(12),
              bottomRight: message.me == FirebaseAuth.instance.currentUser!.uid
                  ? Radius.elliptical(20, 70)
                  : Radius.circular(12),
            )),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat.jm().format(message.datePublished.toDate()).toString(),
              style: TextStyle(fontSize: 8),
            ),
            SizedBox(width: 10),
            Text(
              message.text,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
