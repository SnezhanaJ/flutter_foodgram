import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodgram/util/exception.dart';
import 'model/user_model.dart';
import 'package:uuid/uuid.dart';
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
      await _firebaseFirestore.collection('posts').doc(postId).delete();
      res = 'success';
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

}
