import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:instgram/models/user.dart';
import 'package:instgram/resources/auth_methods.dart';
import 'package:instgram/resources/firestore_methods.dart';

class UserProvider extends ChangeNotifier {
  UserModel? user;
  List<UserModel> users = [];
  final AuthMethods _authMethods = AuthMethods();

  Future<void> refreshUser() async {
    user = await _authMethods.getUserDetails();
    notifyListeners();
  }

  Future<void> getMyFollwing() async {
    users = await FireStoreMethods().getMyFollwing();
    print('==================${users.length}=====================');
    notifyListeners();
  }
}
