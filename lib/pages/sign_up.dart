import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodgram/firestor.dart';
import 'package:foodgram/storage.dart';
import 'package:foodgram/util/exception.dart';
import 'package:foodgram/util/image_picker.dart';
import 'package:foodgram/widgets/navigation.dart';

import '../firebase_auth_services.dart';
import '../widgets/form_container_widget.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {


  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}
class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _auth.setContext(context); // Set the context in initState
  }
  @override
  void dispose(){
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Future<void> Signup({
    required String email,
    required String password,
    required String username,
    required File profile,
  }) async {
    String URL;
    try {
      if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty) {
          // create user with email and password
          await _auth.signUpWithEmailAndPassword(email, password);
          // upload profile image on storage

          if (profile != File('')) {
            URL = await StorageMethod().uploadImageToStorage('Profile', profile);
          } else {
            URL = '';
          }

          // get information with firestor

          await Firebase_Firestor().CreateUser(
            email: email,
            username: username,
            profile: URL == 'gs://flutter-foodgram.appspot.com/person.png'
                ? '' : URL,
          );
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>const Navigations_Screen()),(route)=>false);

      } else {
        throw Exceptions('enter all the fields');
      }
    } on FirebaseException catch (e) {
      throw Exceptions(e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Sign Up"),
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      // ),
      body: Center(
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () async {
                    File imagefilee = await ImagePickerr().uploadImage('gallery');
                    setState(() {
                      _imageFile = imagefilee;
                    });
                  },
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.grey,
                    child: _imageFile == null ? CircleAvatar(
                      radius: 34,
                      backgroundImage: const AssetImage('images/person.png'),
                      backgroundColor: Colors.grey.shade200,
                    )
                        : CircleAvatar(
                      radius: 36,
                      backgroundImage: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      ).image,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FormContainerWidget(
                  controller: _usernameController ,
                  hintText: "Username",
                  isPasswordField: false,
                ),
                const SizedBox(
                  height: 30,
                ),
                FormContainerWidget(
                  controller: _emailController,
                  hintText: "Email",
                  isPasswordField: false,
                ),
                const SizedBox(
                  height: 30,
                ),
                FormContainerWidget(
                  controller: _passwordController,
                  hintText: "Password",
                  isPasswordField: true,
                ),
                const SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: (){
                      Signup(email: _emailController.text, password: _passwordController.text, username: _usernameController.text, profile: _imageFile ?? File(''));
                      },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text("Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),)),
                  ),
                ),
                const SizedBox(height: 20,),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    const SizedBox(width: 5,),
                    GestureDetector(
                      onTap: (){
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>const LoginPage()),(route) =>false);
                      },
                      child: const Text("Login", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),
                    )
                  ],)
              ],
            ),)
      ),
    );
  }
}