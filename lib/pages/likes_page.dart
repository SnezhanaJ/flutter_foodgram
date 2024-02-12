
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodgram/firestor.dart';
import 'package:foodgram/model/user_model.dart';
class LikesPage extends StatefulWidget {
  const LikesPage({super.key});

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
  _getUserData() async {

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
        title: const Text('Foodgram'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

      ),
      body: FutureBuilder(
        future: Firebase_Firestor().getUser(_auth.currentUser!.uid),
        builder: (context, AsyncSnapshot<Usermodel> snapshot) {
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
                }
                final List<DocumentSnapshot> documents = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot document = documents[index];
                    final Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    final List<dynamic> likes = data['like'];

                    // Check if there are any likes on the post
                    if (likes.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display the image
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                color: Colors.amber,
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
                                      for (var username in likes)
                                        ListTile(
                                          title: Text('$username liked your photo'),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                          // const Divider(),

                        ],
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'You have no notifications yet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
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
