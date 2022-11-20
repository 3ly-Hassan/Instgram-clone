import 'package:flutter/material.dart';
import 'package:instgram/providers/user_provider.dart';
import 'package:instgram/screens/chat_screen.dart';
import 'package:instgram/utils/colors.dart';
import 'package:provider/provider.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: const Text(
            'Chats',
            style: TextStyle(color: primaryColor),
          ),
        ),
        body: Consumer<UserProvider>(
            builder: (context, value, child) => value.users.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  )
                : ListView.builder(
                    itemCount: value.users.length,
                    itemBuilder: (context, index) => ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(user: value.users[index]),
                        ));
                      },
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundImage:
                            NetworkImage(value.users[index].photoUrl),
                      ),
                      title: Text(
                        value.users[index].username,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                      subtitle: Text(
                        'Last Message',
                        style: TextStyle(color: secondaryColor),
                      ),
                      trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.camera_alt_outlined,
                            color: secondaryColor,
                          )),
                    ),
                  )));
  }
}
