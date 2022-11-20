import 'package:flutter/material.dart';
import 'package:instgram/models/post.dart';
import 'package:instgram/providers/post_provider.dart';
import 'package:instgram/providers/user_provider.dart';
import 'package:instgram/screens/comments_screen.dart';
import 'package:instgram/utils/colors.dart';
import 'package:instgram/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../resources/firestore_methods.dart';
import '../utils/utils.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isAnimating = false;
  final TextEditingController _commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    UserModel user = Provider.of<UserProvider>(context, listen: false).user!;
    final provider = Provider.of<PostProvider>(context, listen: false);
    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.post.profImage),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.post.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Text(
                      //   '9 hours ago',
                      //   style: TextStyle(color: secondaryColor, fontSize: 12),
                      // ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              shrinkWrap: true,
                              children: ['Delete']
                                  .map((e) => InkWell(
                                        onTap: () async {
                                          await FireStoreMethods()
                                              .deletePost(widget.post.postId);
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 16,
                                            ),
                                            child: Text(e)),
                                      ))
                                  .toList(),
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.more_vert))
              ],
            ),
          ),
          //image section
          GestureDetector(
            onDoubleTap: () {
              setState(() {
                provider.likePost(widget.post, true, user.uid);
                isAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * .35,
                  width: double.infinity,
                  child: Image.network(
                    widget.post.postUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isAnimating ? 1 : 0,
                  child: LikeAnimation(
                      onEnd: () {
                        setState(() {
                          isAnimating = false;
                        });
                      },
                      isAnimating: isAnimating,
                      duration: const Duration(milliseconds: 1000),
                      smallLike: false,
                      child: const Icon(Icons.favorite,
                          color: primaryColor, size: 120)),
                )
              ],
            ),
          ),
          // Like Comment section
          Row(
            children: [
              LikeAnimation(
                smallLike: true,
                duration: const Duration(milliseconds: 500),
                isAnimating: !widget.post.likes.contains(user.uid),
                child: Consumer<PostProvider>(
                  builder: (context, value, child) => IconButton(
                    onPressed: () {
                      provider.likePost(widget.post, false, user.uid);
                    },
                    icon: widget.post.likes.contains(user.uid)
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : const Icon(Icons.favorite_border),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        CommentsScreen(postId: widget.post.postId),
                  ));
                },
                icon: const Icon(Icons.comment_rounded),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.send),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border),
              ),
            ],
          ),
          //description and no.comments
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<PostProvider>(
                  builder: (context, value, child) => Text(
                    '${widget.post.likes.length} likes',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                        style: const TextStyle(color: primaryColor),
                        children: [
                          TextSpan(
                            text: '${widget.post.username} ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: widget.post.description,
                          ),
                        ]),
                  ),
                ),
                widget.post.comments != 0
                    ? InkWell(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'View all ${widget.post.comments} comments',
                            style: const TextStyle(
                              fontSize: 16,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                          Provider.of<UserProvider>(context, listen: false)
                              .user!
                              .photoUrl),
                      radius: 12,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        onEditingComplete: () => postComment(
                          user.uid,
                          user.username,
                          user.photoUrl,
                        ),
                        decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: mobileBackgroundColor,
                            filled: true,
                            hintStyle:
                                TextStyle(color: secondaryColor, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    widget.post.datePublished.toDate().year ==
                            DateTime.now().year
                        ? DateFormat.MMMd()
                            .format(widget.post.datePublished.toDate())
                            .toString()
                        : DateFormat.yMMMd()
                            .format(widget.post.datePublished.toDate())
                            .toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void postComment(String uid, String name, String profilePic) async {
    try {
      String res = await FireStoreMethods().postComment(
        widget.post.postId,
        _commentController.text,
        uid,
        name,
        profilePic,
      );

      if (res != 'success') {
        showSnackBar(res, context);
      }
      setState(() {
        _commentController.text = "";
      });
    } catch (err) {
      showSnackBar(err.toString(), context);
    }
  }
}
