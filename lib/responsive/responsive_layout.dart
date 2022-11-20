import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instgram/models/user.dart';
import 'package:instgram/providers/user_provider.dart';
import 'package:instgram/screens/audio_screen.dart';
import 'package:instgram/screens/video_screen.dart';
import 'package:instgram/utils/global_vars.dart';
import 'package:instgram/widgets/call_button.dart';
import 'package:provider/provider.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;

  const ResponsiveLayout(
      {super.key,
      required this.webScreenLayout,
      required this.mobileScreenLayout});

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> stream;
  @override
  void initState() {
    super.initState();
    print('getting the data');
    addData();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > webScreenSize) {
        return widget.webScreenLayout;
      }
      return widget.mobileScreenLayout;
    });
  }

  Future<void> addData() async {
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.refreshUser();
    stream = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    listenToCalls();
  }

  void listenToCalls() async {
    stream.listen((event) async {
      if ((event.data()!['inCall'] == null || !event.data()!['inCall']) &&
          event.data()!['ring'] != null) {
        final callerSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(event.data()!['ring'])
            .get();
        UserModel caller = UserModel.fromJson(callerSnap.data()!);
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  actionsPadding: const EdgeInsets.only(bottom: 20),
                  actionsAlignment: MainAxisAlignment.spaceAround,
                  title: Text(
                    'A ${event.data()!['ringType']} call is coming',
                    style: const TextStyle(fontSize: 18),
                  ),
                  content: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(caller.photoUrl),
                        radius: 20,
                      ),
                      Text('  ' + caller.username)
                    ],
                  ),
                  actions: [
                    CallButton(
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(context.read<UserProvider>().user!.uid)
                              .update({'ring': null, 'inCall': true});

                          Navigator.of(context).pop();
                          event.data()!['ringType'] == 'video'
                              ? Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => VideoScreen(
                                    uId: context.read<UserProvider>().user!.uid,
                                  ),
                                ))
                              : Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => AudioScreen(
                                    photoUrl: caller.photoUrl,
                                    uId: context.read<UserProvider>().user!.uid,
                                  ),
                                ));
                        },
                        icon: Icons.call,
                        color: Colors.green),
                    CallButton(
                        onTap: () {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(context.read<UserProvider>().user!.uid)
                              .update({'ring': null});
                          Navigator.of(context).pop();
                        },
                        icon: Icons.call_end,
                        color: Colors.red),
                  ],
                ),
            barrierDismissible: false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
