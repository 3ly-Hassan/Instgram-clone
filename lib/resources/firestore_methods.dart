import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:instgram/models/message.dart';
import 'package:instgram/models/post.dart';
import 'package:instgram/models/user.dart';
import 'package:instgram/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload post
  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage) async {
    String res = 'Some error occurred';
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId = const Uuid().v1();
      PostModel post = PostModel(
        description: description,
        uid: uid,
        datePublished: Timestamp.fromDate(DateTime.now()),
        username: username,
        postId: postId,
        postUrl: photoUrl,
        profImage: profImage,
        likes: [],
        comments: 0,
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<List<PostModel>> getPost() async {
    List<PostModel> posts = [];
    try {
      var postsQuery =
          await _firestore.collection('posts').orderBy('datePublished').get();
      for (var element in postsQuery.docs) {
        posts.add(PostModel.fromJson(element.data()));
      }

      return posts;
    } catch (e) {
      return posts;
    }
  }

  Future<void> likePost(
      String postId, String uId, List likes, bool fromStack) async {
    try {
      if (fromStack && likes.contains(uId)) {
        return;
      } else {
        if (likes.contains(uId)) {
          await _firestore.collection('posts').doc(postId).update({
            'likes': FieldValue.arrayRemove([uId]),
          });
        } else {
          await _firestore.collection('posts').doc(postId).update({
            'likes': FieldValue.arrayUnion([uId]),
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // Post comment
  Future<String> postComment(
      postId, String text, String uid, String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        _firestore
            .collection('posts')
            .doc(postId)
            .update({'comments': FieldValue.increment(1)});
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Delete Post
  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // get my following
  Future<List<UserModel>> getMyFollwing() async {
    List<UserModel> users = [];
    final userDoc = await _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final List following = userDoc.data()!['following'];
    for (String id in following) {
      final userDoc = await _firestore.collection('users').doc(id).get();
      UserModel user = UserModel.fromJson(userDoc.data()!);
      users.add(user);
    }
    return users;
  }

  //send message
  Future<String> sendMessage(String text, String uid) async {
    String res = 'Some error occurred';
    try {
      final messageForMe = _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('chats')
          .doc(uid)
          .collection('messages')
          .doc();
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('chats')
          .doc(uid)
          .collection('messages')
          .doc(messageForMe.id)
          .set(Message(
                  uid: messageForMe.id,
                  text: text,
                  me: FirebaseAuth.instance.currentUser!.uid,
                  datePublished: Timestamp.fromDate(DateTime.now()))
              .toJson());
      final messageForHim = _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('chats')
          .doc(uid)
          .collection('messages')
          .doc();
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('chats')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('messages')
          .doc(messageForHim.id)
          .set(Message(
                  uid: messageForHim.id,
                  text: text,
                  me: FirebaseAuth.instance.currentUser!.uid,
                  datePublished: Timestamp.fromDate(DateTime.now()))
              .toJson());

      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
