import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodgram/firestor.dart';
import 'package:foodgram/widgets/post_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final   FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String? loggedUser;


  @override
  void initState() {
    _getUserData();
  }

  // Method to retrieve user data
  Future<void> _getUserData() async {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:  Text("Foodgram",
          style: GoogleFonts.getFont('Euphoria Script',
            textStyle: const TextStyle(
              fontSize: 40, // Adjust the font size as needed
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,

      ),
      body: CustomScrollView(
        slivers: [
          StreamBuilder(
            stream: _firebaseFirestore
                .collection('posts')
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // Create a list to hold widgets
                    List<Widget> widgets = [];
                    // Add the PostWidget
                    widgets.add(PostWidget(snapshot.data?.docs[index].data(), loggedUser));
                    // Add a Divider if this is not the last post
                    if (index < snapshot.data!.docs.length - 1) {
                      widgets.add(const Divider());
                    }
                    // Return the column with the list of widgets
                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widgets,
                      ),
                    );
                    // return PostWidget(snapshot.data?.docs[index].data(),loggedUser);
                  },
                  childCount:
                  snapshot.data == null ? 0 : snapshot.data!.docs.length,
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
