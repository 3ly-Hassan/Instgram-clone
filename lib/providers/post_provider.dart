import 'package:flutter/cupertino.dart';
import 'package:instgram/models/post.dart';
import 'package:instgram/resources/firestore_methods.dart';

class PostProvider extends ChangeNotifier {
  List<PostModel> posts = [];
  Future<void> getPosts() async {
    posts = await FireStoreMethods().getPost();
    notifyListeners();
  }

  void likePost(PostModel postModel, bool fromStack, String uId) {
    FireStoreMethods()
        .likePost(postModel.postId, uId, postModel.likes, fromStack);
    if (fromStack && postModel.likes.contains(uId)) {
      return;
    } else {
      if (postModel.likes.contains(uId)) {
        postModel.likes.remove(uId);
        notifyListeners();
      } else {
        postModel.likes.add(uId);
        notifyListeners();
      }
    }
  }
}
