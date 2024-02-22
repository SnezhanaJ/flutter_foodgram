import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodgram/firestor.dart';
import 'package:foodgram/model/user_model.dart';
import 'package:google_fonts/google_fonts.dart';

class LikesPage extends StatefulWidget {
  const LikesPage({Key? key}) : super(key: key);

  @override
  State<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  late Usermodel user;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Method to retrieve user data
  Future<void> _getUserData() async {
    try {
      // Retrieve user data from Firestore
      final userData = await Firebase_Firestor().getUser(_auth.currentUser!.uid);
      setState(() {
        user = userData;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
    }
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
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<Usermodel>(
        future: Firebase_Firestor().getUser(_auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final List<DocumentSnapshot> documents = snapshot.data!.docs;

                if (documents.isEmpty) {
                  return Center(
                    child: Text(
                      'No posts found for ${user.username}',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  );
                }
                // Check for likes in all documents
                bool hasLikes = documents.any((document) {
                  final Map<String, dynamic>? data =
                  document.data() as Map<String, dynamic>?;
                  final List<dynamic>? likes = data?['like'];
                  return likes != null && likes.isNotEmpty;
                });

                // If there are no likes in any of the documents, display a message
                if (!hasLikes) {
                  return Center(
                    child: Text(
                      'No posts with likes found for ${user.username}',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot document = documents[index];
                    final Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    final List<dynamic> likes = data['like'];
                    print(likes);

                    if (likes.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    color: Colors.lightGreen,
                                    image: DecorationImage(
                                      image: NetworkImage(data['postImage']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // for (var username in likes)
                                          if(likes.length>1)
                                            ListTile(
                                              title: Text('${likes[0]},${likes[1]} and others liked your photo'),
                                            )
                                          else
                                            ListTile(
                                              title: Text('${likes[0]} liked your photo'),
                                            ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }else{
                      return Container();
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
