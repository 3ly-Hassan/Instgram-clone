import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instgram/providers/post_provider.dart';
import 'package:instgram/providers/user_provider.dart';
import 'package:instgram/resources/firestore_methods.dart';
import 'package:instgram/screens/chats_screen.dart';
import 'package:instgram/utils/colors.dart';
import 'package:instgram/widgets/post_card.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: SvgPicture.asset(
          'assets/ic_instagram.svg',
          color: primaryColor,
          height: 32,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).getMyFollwing();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ChatsScreen(),
              ));
            },
            icon: const Icon(Icons.message_rounded),
          )
        ],
      ),
      body: Provider.of<PostProvider>(context).posts.isEmpty ||
              Provider.of<UserProvider>(context).user == null
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : RefreshIndicator(
              child: ListView.builder(
                itemCount: Provider.of<PostProvider>(context, listen: false)
                    .posts
                    .length,
                itemBuilder: (context, index) => PostCard(
                    post: Provider.of<PostProvider>(context, listen: false)
                        .posts[index]),
              ),
              onRefresh: () {
                return context.read<PostProvider>().getPosts();
              }),
    );
  }
}
