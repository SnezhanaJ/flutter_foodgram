import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../firestor.dart';
import '../model/user_model.dart';
import '../storage.dart';
import '../util/image_picker.dart';
class EditProfilePage extends StatefulWidget {
  final String uid;
  const EditProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _usernameController = TextEditingController();
  File? _profileImage;
  late Usermodel user;
  late String? currentUsername;
  bool isLoading = false;



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
        currentUsername = user.username;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    try {
      String newUsername = _usernameController.text.trim();
      String profileImageUrl = '';
      if (_profileImage != null) {
        profileImageUrl = await StorageMethod().uploadImageToStorage('Profile', _profileImage!);
        // Delete the previous profile image if it exists
        if( user.profile != null  && user.profile.isNotEmpty){
          await FirebaseStorage.instance.refFromURL(user.profile).delete();
        }
      }

      await Firebase_Firestor().updateUserProfile(
        uid: widget.uid,
        newUsername: newUsername,
        newProfilePictureUrl: profileImageUrl,
      );
      // Update user's posts
      await Firebase_Firestor().UpdatePost(
        userId: widget.uid,
        newUsername: newUsername,
        newProfilePictureUrl: profileImageUrl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile Updated')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return  isLoading
        ? const Center(
      child: CircularProgressIndicator(), // Circular Progress Indicator
    )
        : Scaffold(
      appBar: AppBar(title:
      Text("Foodgram",
        style: GoogleFonts.getFont('Euphoria Script',
          textStyle: const TextStyle(
            fontSize: 40, // Adjust the font size as needed
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () async {
                File imagefilee = await ImagePickerr().uploadImage('gallery');
                setState(() {
                  _profileImage = imagefilee;
                });
              },
              child: CircleAvatar(
                radius: 38,
                backgroundColor: Colors.grey,
                child: _profileImage == null
                    ? CircleAvatar(
                  radius: 34,
                  backgroundImage: user.profile != null  && user.profile.isNotEmpty
                      ? NetworkImage(user.profile) as ImageProvider<Object>?
                      : const AssetImage('images/person.png'),
                  backgroundColor: Colors.grey.shade200,
                )
                    : CircleAvatar(
                  radius: 36,
                  backgroundImage: Image.file(
                    _profileImage!,
                    fit: BoxFit.cover,
                  ).image,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(child: Text("Change your profile picture")),
            const SizedBox(height: 20),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: "Current Username: ",
                    style: TextStyle(fontSize: 16),
                  ),
                  TextSpan(
                    text: currentUsername, // Assuming currentUsername is a String variable
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'New Username'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _updateProfile();
              },
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
