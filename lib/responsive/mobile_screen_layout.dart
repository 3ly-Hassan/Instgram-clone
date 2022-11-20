import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instgram/providers/user_provider.dart';
import 'package:instgram/screens/add_post_screen.dart';
import 'package:instgram/screens/feed_screen.dart';
import 'package:instgram/screens/profile_screen.dart';
import 'package:instgram/screens/search_screen.dart';
import 'package:instgram/utils/colors.dart';
import 'package:provider/provider.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int page = 0;
  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController();
    return Scaffold(
      body: PageView(
        controller: pageController,
        physics: const BouncingScrollPhysics(),
        children: [
          const Home(),
          const SearchScreen(),
          const AddPostScreen(),
          Center(child: Text(page.toString())),
          ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid)
        ],
        onPageChanged: (value) {
          setState(() {
            page = value;
          });
        },
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: mobileBackgroundColor,
        activeColor: primaryColor,
        onTap: (value) {
          setState(() {
            page = value;
          });
          pageController.animateToPage(value,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        },
        currentIndex: page,
        inactiveColor: secondaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            backgroundColor: primaryColor,
          ),
        ],
      ),
    );
  }
}
