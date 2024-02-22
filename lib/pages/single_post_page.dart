import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodgram/firestor.dart';
import 'package:foodgram/widgets/post_widget.dart';
import 'package:google_fonts/google_fonts.dart';
class SinglePostPage extends StatefulWidget {
  final String postId;
  const SinglePostPage({Key? key, required this.postId}) : super(key: key);

  @override
  State<SinglePostPage> createState() => _SinglePostPageState();
}

class _SinglePostPageState extends State<SinglePostPage> {

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? loggedUser;
  Map<String, dynamic>? postData;
  late Stream<DocumentSnapshot>? postStream;


  Future<void> fetchPost() async {
    try {
      // Fetch the post data from Firestore
      QuerySnapshot querySnapshot = await _firebaseFirestore
          .collection('posts')
          .where('postId', isEqualTo: widget.postId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        postData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        if (kDebugMode) {
          print('No post found with postId: ${widget.postId}');
        }
      }

      // Update the state with the fetched post data
      setState(() {
        postData = postData;
      });
    } catch (e) {
      // Handle any potential errors
      if (kDebugMode) {
        print('Error fetching post: $e');
      }
    }
  }
  // Method to retrieve user data
  _getUserData() async {
    try {
      // Retrieve user data from Firestore
      final userData = await Firebase_Firestor().getUser(_auth.currentUser!.uid);
      setState(() {
        loggedUser = userData.username;

      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
    }

  }

  @override
  void initState() {
    super.initState();
    _getUserData();
    fetchPost();
    postStream = _firebaseFirestore
        .collection('posts')
        .doc(widget.postId)
        .snapshots();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title:  Text('Foodgram',
          style: GoogleFonts.getFont('Euphoria Script',
            textStyle: const TextStyle(
              fontSize: 40, // Adjust the font size as needed
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),),
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: postStream,
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
            final postData = snapshot.data!.data() as Map<String, dynamic>?;
            return postData != null
                ? PostWidget(postData, loggedUser)
                : const Center(
              child: Text('Post not found'),
            );
          }
        },
      ),
    );
  }
}
