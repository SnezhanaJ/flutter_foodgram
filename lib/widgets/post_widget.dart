import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:foodgram/firestor.dart';
import 'package:foodgram/pages/show_post_location_page.dart';
import 'package:foodgram/toast.dart';
import 'package:foodgram/util/image_cached.dart';
import 'package:foodgram/widgets/like_animation.dart';

import '../pages/comment_page.dart';

class PostWidget extends StatefulWidget {
  final snapshot;
  final String? loggedUser;

  PostWidget(this.snapshot, this.loggedUser, {super.key});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLikeAnimation = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 375,
          height: 60,
          color: Colors.white,
          child: Center(
            child: ListTile(
              leading: ClipOval(
                child: SizedBox(
                  width: 35,
                  height: 35,
                  child: CachedImage(widget.snapshot['profileImage']),
                ),
              ),
              title: Text(
                widget.snapshot['username'],
                style: TextStyle(fontSize: 13),
              ),
              subtitle: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PostLocation(
                            postLocation: widget.snapshot['location'])),
                  );
                },
                child: Text(
                  widget.snapshot['location'],
                  style: TextStyle(fontSize: 11),
                ),
              ),
              trailing: widget.snapshot['username'] == widget.loggedUser
                  ? GestureDetector(
                      onTap: () async {
                        bool confirmDelete = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Post"),
                            content: const Text(
                                "Are you sure you want to delete this post?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(
                                      false); // User doesn't want to delete
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(true); // User confirmed deletion
                                },
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );
                        if (confirmDelete == true) {
                          String deleteResult = await Firebase_Firestor()
                              .deletePost(widget.snapshot['postId']);
                          if (deleteResult == 'success') {
                            showToast(context,
                                message: 'The post has been deleted');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Failed to delete post: $deleteResult"),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                      child: const Icon(Icons.more_horiz),
                    )
                  : SizedBox(),
            ),
          ),
        ),
        GestureDetector(
          onDoubleTap: () async {
            print(
                'Double tap detected'); // Add this line to check if the double tap is detected
            await Firebase_Firestor().likePost(widget.snapshot['postId'],
                widget.loggedUser, widget.snapshot['like']);
            setState(() {
              isLikeAnimation = true;
            });
          },
          child: Stack(alignment: Alignment.center, children: [
            Center(
              child: Container(
                  width: 375,
                  height: 375,
                  child: CachedImage(widget.snapshot['postImage'])),
            ),
            AnimatedOpacity(
              duration: const Duration(
                milliseconds: 200,
              ),
              opacity: isLikeAnimation ? 1 : 0,
              child: LikeAnimation(
                isAnimating: isLikeAnimation,
                duration: const Duration(milliseconds: 400),
                onEnd: () {
                  setState(() {
                    isLikeAnimation = false;
                  });
                },
                child:
                    const Icon(Icons.favorite, color: Colors.white, size: 120),
              ),
            ),
          ]),
        ),
        Container(
          width: 375,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              Row(
                children: [
                  const SizedBox(width: 14),
                  LikeAnimation(
                    isAnimating:
                        widget.snapshot['like'].contains(widget.loggedUser),
                    smallLike: true,
                    child: IconButton(
                      icon: widget.snapshot['like'].contains(widget.loggedUser)
                          ? const Icon(Icons.favorite, color: Colors.red)
                          : const Icon(Icons.favorite_outline),
                      onPressed: () async {
                        await Firebase_Firestor().likePost(
                            widget.snapshot['postId'],
                            widget.loggedUser,
                            widget.snapshot['like']);
                        setState(() {
                          isLikeAnimation = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 17),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(postId:widget.snapshot['postId']), // Replace CommentPage with your actual comment page
                        ),
                      );
                    },
                    child: const Icon(Icons.mode_comment_outlined),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 19,
                  top: 8,
                  bottom: 8,
                ),
                child: Text(
                  widget.snapshot['like'].length.toString() + ' likes',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Text(
                      widget.snapshot['username'] + '  ',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.snapshot['caption'],
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 20, bottom: 8),
                child: Text(
                  formatDate(widget.snapshot['time'].toDate(),
                      [yyyy, '-', mm, '-', dd]),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
