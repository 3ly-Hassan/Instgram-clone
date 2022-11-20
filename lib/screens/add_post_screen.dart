// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instgram/models/user.dart';
import 'package:instgram/providers/user_provider.dart';
import 'package:instgram/resources/firestore_methods.dart';
import 'package:instgram/utils/colors.dart';
import 'package:instgram/utils/utils.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? file;
  bool isLoading = false;
  TextEditingController descriptionController = TextEditingController();
  selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Take a photo'),
              onPressed: () async {
                Navigator.of(context).pop();
                file = await pickImage(ImageSource.camera);
                setState(() {});
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Choose from gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                file = await pickImage(ImageSource.gallery);
                setState(() {});
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Cancel'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    UserModel? user = Provider.of<UserProvider>(context).user;
    return file == null
        ? Center(
            child: IconButton(
              icon: const Icon(Icons.upload),
              onPressed: () {
                selectImage(context);
              },
            ),
          )
        : Scaffold(
            appBar: AppBar(
              actions: [
                TextButton(
                  onPressed: () =>
                      postImage(user!.uid, user.username, user.photoUrl),
                  child: const Text(
                    'Post',
                    style: TextStyle(
                        color: blueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ],
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    file = null;
                  });
                },
              ),
              title: const Text('Add Post'),
              backgroundColor: mobileBackgroundColor,
            ),
            body: Column(
              children: [
                if (isLoading) const LinearProgressIndicator(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    user != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(user.photoUrl),
                          )
                        : const CircularProgressIndicator(color: primaryColor),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .4,
                      child: TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                            hintText: 'Write a caption now...',
                            border: InputBorder.none),
                        maxLines: 8,
                      ),
                    ),
                    SizedBox(
                      width: 45,
                      child: AspectRatio(
                          aspectRatio: 487 / 451,
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: MemoryImage(file!),
                                    fit: BoxFit.fill,
                                    alignment: FractionalOffset.topCenter)),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  void postImage(
    String uid,
    String username,
    String profImage,
  ) async {
    setState(() {
      isLoading = true;
    });
    try {
      String res = await FireStoreMethods().uploadPost(
        descriptionController.text,
        file!,
        uid,
        username,
        profImage,
      );
      if (res == 'success') {
        showSnackBar('Posted Successfully', context);
        setState(() {
          file = null;
        });
      } else {
        showSnackBar(res, context);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
      setState(() {
        isLoading = false;
      });
    }
  }
}
