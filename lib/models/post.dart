import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String description;
  final String uid;
  final Timestamp datePublished;
  final String username;
  final String postId;
  final String postUrl;
  final String profImage;
  final List likes;
  final int comments;

  const PostModel({
    required this.description,
    required this.uid,
    required this.datePublished,
    required this.username,
    required this.postId,
    required this.postUrl,
    required this.profImage,
    required this.likes,
    required this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'uid': uid,
      'description': description,
      'postId': postId,
      'datePublished': datePublished,
      'postUrl': postUrl,
      'profImage': profImage,
      'likes': likes,
      'comments': comments,
    };
  }

  static PostModel fromJson(Map<String, dynamic> json) {
    return PostModel(
      description: json['description'],
      uid: json['uid'],
      datePublished: json['datePublished'],
      username: json['username'],
      postId: json['postId'],
      postUrl: json['postUrl'],
      profImage: json['profImage'],
      likes: json['likes'],
      comments: json['comments'],
    );
  }
}
