import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodgram/firestor.dart';
import 'package:foodgram/model/user_model.dart';
import 'package:foodgram/pages/edit_profile_page.dart';
import 'package:foodgram/pages/login_page.dart';
import 'package:foodgram/pages/single_post_page.dart';
import 'package:foodgram/toast.dart';
import 'package:foodgram/widgets/follow_button.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int post_length = 0;
  late Usermodel user;
  String? loggedUser;
  bool isLoading = false;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Method to retrieve user data
  _getUserData() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Retrieve user data from Firestore
      final userData = await Firebase_Firestor().getUser(widget.uid);
      setState(() {
        user = userData;
        loggedUser = user.username;
        followers = user.followers.length;
        following = user.following.length;
        isFollowing = user.followers.contains(_auth.currentUser!.uid);
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Foodgram',
          style: GoogleFonts.getFont(
            'Euphoria Script',
            textStyle: const TextStyle(
              fontSize: 40, // Adjust the font size as needed
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          widget.uid == _auth.currentUser!.uid
              ? IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                        (route) => false);
                    showToast(context, message: "Successfully signed out");
                  },
                  icon: const Icon(Icons.logout))
              : const SizedBox(),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(), // Circular Progress Indicator
            )
          : ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ... (existing code)
                    ],
                  ),
                ),
                //profile details
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$following',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Following',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: user.profile != null
                            ? NetworkImage(user.profile)
                            : null,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$followers',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Followers',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widget.uid == _auth.currentUser!.uid
                          ? Container(
                        padding: const EdgeInsets.only(top: 2),
                        child: TextButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfilePage(uid: _auth.currentUser!.uid,)),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              border: Border.all(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            alignment: Alignment.center,
                            width: 250,
                            height: 27,
                            child: const Text(
                              "Edit profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                          : isFollowing
                              ? FollowButton(
                                  text: 'Unfollow',
                                  backgroundColor: Colors.white,
                                  textColor: Colors.black,
                                  borderColor: Colors.grey,
                                  function: () async {
                                    await Firebase_Firestor().followUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      user.uid,
                                    );

                                    setState(() {
                                      isFollowing = false;
                                      followers--;
                                    });
                                  },
                                )
                              : FollowButton(
                                  text: 'Follow',
                                  backgroundColor: Colors.lightGreen,
                                  textColor: Colors.white,
                                  borderColor: Colors.lightGreen,
                                  function: () async {
                                    await Firebase_Firestor().followUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      user.uid,
                                    );

                                    setState(() {
                                      isFollowing = true;
                                      followers++;
                                    });
                                  },
                                )
                    ],
                  ),
                ),
                const SizedBox(width: 50),
                const Divider(),
                const SizedBox(width: 50),
                SizedBox(
                  height: 1000,
                  child: FutureBuilder(
                    future: Firebase_Firestor().getUser(widget.uid),
                    builder: (context, AsyncSnapshot<Usermodel> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child:
                              CircularProgressIndicator(), // Circular Progress Indicator
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        final user = snapshot.data!;
                        return StreamBuilder<QuerySnapshot>(
                          stream: _firebaseFirestore
                              .collection('posts')
                              .where('username', isEqualTo: user.username)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child:
                                    CircularProgressIndicator(), // Circular Progress Indicator
                              );
                            }
                            final List<DocumentSnapshot> documents =
                                snapshot.data!.docs;
                            return GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 4.0,
                              ),
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                final DocumentSnapshot document =
                                    documents[index];
                                final Map<String, dynamic> data =
                                    document.data()! as Map<String, dynamic>;
                                final String imageUrl = data['postImage'];
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SinglePostPage(
                                          postId: data['postId']),
                                    ),
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
