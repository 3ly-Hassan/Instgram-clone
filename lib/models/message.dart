import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String uid;
  final String text;
  final String me;
  final Timestamp datePublished;
  const Message({
    required this.uid,
    required this.text,
    required this.me,
    required this.datePublished,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'uId': uid,
      'datePublished': datePublished,
      'me': me,
    };
  }

  static Message fromJson(Map<String, dynamic> json) {
    return Message(
        me: json['me'],
        uid: json['uId'],
        datePublished: json['datePublished'],
        text: json['text']);
  }
}
