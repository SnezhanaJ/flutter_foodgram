import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:foodgram/pages/profile_page.dart';


class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Form(
          child: TextFormField(
            controller: searchController,
            decoration:
            const InputDecoration(labelText: 'Search for a user...'),
            onFieldSubmitted: (String _) {
              setState(() {
                isShowUsers = true;
              });
            },
          ),
        ),
      ),
      body: isShowUsers
          ? FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .where(
          'username',
          isGreaterThanOrEqualTo: searchController.text,
        )
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Handle case where no user is found with the entered username
            return const Center(
              child: Text('No user found with the entered username.'),
            );
          }
          return ListView.builder(
            itemCount: (snapshot.data! as dynamic).docs.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      uid: (snapshot.data! as dynamic).docs[index]['uid'],
                    ),
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      (snapshot.data! as dynamic).docs[index]['profile'],
                    ),
                    radius: 16,
                  ),
                  title: Text(
                    (snapshot.data! as dynamic).docs[index]['username'],
                  ),
                ),
              );
            },
          );
        },
      )
          : FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('time')
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return MasonryGridView.count(
            crossAxisCount: 3,
            itemCount: (snapshot.data! as dynamic).docs.length,
            itemBuilder: (context, index) => Image.network(
              (snapshot.data! as dynamic).docs[index]['postImage'],
              fit: BoxFit.cover,
            ),
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          );
        },
      ),
    );
  }
}