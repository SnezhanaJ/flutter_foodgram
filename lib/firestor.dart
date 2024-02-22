import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:foodgram/util/exception.dart';
import 'model/user_model.dart';
import 'storage.dart';


class Firebase_Firestor {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> CreateUser({
    required String email,
    required String username,
    required String profile,
  }) async {
    await _firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .set({
      'email': email,
      'username': username,
      'profile': profile,
      'followers': [],
      'following': [],
      'uid': _auth.currentUser!.uid,
    });
    return true;
  }

  Future<Usermodel> getUser(String uid) async {
    try {
      final user = await _firebaseFirestore
          .collection('users').where('uid',isEqualTo: uid)
          // .doc(_auth.currentUser!.uid)
          .get();
      // final snapuser = user.data()!;
      final snapuser = user.docs.first.data();
      return Usermodel(
          snapuser['email'],
          snapuser['followers'],
          snapuser['following'],
          snapuser['profile'],
          snapuser['username'],
      snapuser['uid']);
    } on FirebaseException catch (e) {
      throw Exceptions(e.message.toString());
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    String? newUsername,
    String? newProfilePictureUrl,
  }) async {
    try {
      final userDoc = _firebaseFirestore.collection('users').doc(uid);

      if (newUsername != null) {
        await userDoc.update({'username': newUsername});
      }

      if (newProfilePictureUrl != null) {
        await userDoc.update({'profile': newProfilePictureUrl});
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }


  Future<bool> CreatePost({
    required File postImage,
    required String caption,
    required String location,
  }) async {
    DateTime data = new DateTime.now();
    Usermodel user = await getUser(_auth.currentUser!.uid);
    String photoUrl = await StorageMethod().uploadImageToStorage('posts', postImage);
    var docRef = await _firebaseFirestore.collection('posts').doc();
    await docRef.set({
      'postImage': photoUrl,
      'username': user.username,
      'profileImage': user.profile,
      'caption': caption,
      'location': location,
      'postId': docRef.id,
      'uid': _auth.currentUser!.uid,
      'like': [],
      'time': data
    });
    return true;
  }

  Future<void> UpdatePost({
    required String userId,
    required String newUsername,
    required String newProfilePictureUrl,
  }) async {
    try {
      // Query for all posts by the user
      final postsQuery = await _firebaseFirestore
          .collection('posts')
          .where('uid', isEqualTo: userId)
          .get();

      // Update each post with the new profile information
      final batch = _firebaseFirestore.batch();
      postsQuery.docs.forEach((postDoc) {
        batch.update(postDoc.reference, {
          'username': newUsername,
          'profileImage': newProfilePictureUrl,
        });
      });

      // Commit the batch update
      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user posts: $e');
      }
      throw e; // Optionally, re-throw the error to handle it in the caller
    }
  }


  Future<String> likePost(String postId, String? uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firebaseFirestore.collection('posts').doc(postId).update({
          'like': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firebaseFirestore.collection('posts').doc(postId).update({
          'like': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Delete Post
  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      var postDoc = await _firebaseFirestore.collection('posts').doc(postId).get();
      if (postDoc.exists) {
        // Get the photoImage URL from the post document
        String postImageUrl = postDoc.data()?['postImage'];

        // Delete the post document
        await _firebaseFirestore.collection('posts').doc(postId).delete();

        // Delete the image from Firebase Storage
        if (postImageUrl != null) {
          await FirebaseStorage.instance.refFromURL(postImageUrl).delete();
        }
        res = 'success';
      }else{
          res = 'success';

        }

    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
      await _firebaseFirestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firebaseFirestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firebaseFirestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firebaseFirestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firebaseFirestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
       print(e.toString());
    }
  }

  // Post comment
  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        var docRef = await _firebaseFirestore.collection('posts') .doc(postId)
            .collection('comments').doc();
        String commentId = docRef.id;
        _firebaseFirestore.collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

}
