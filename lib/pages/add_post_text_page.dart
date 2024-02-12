import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:foodgram/firestor.dart';
import 'package:foodgram/storage.dart';


class AddPostTextScreen extends StatefulWidget {
  File _file;
  AddPostTextScreen(this._file, {super.key});

  @override
  State<AddPostTextScreen> createState() => _AddPostTextScreenState();
}

class _AddPostTextScreenState extends State<AddPostTextScreen> {
  final caption = TextEditingController();
  final location = TextEditingController();
  bool islooding = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'New post',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    islooding = true;
                  });
                  // String post_url = await StorageMethod()
                  //     .uploadImageToStorage('post', widget._file);
                  await Firebase_Firestor().CreatePost(
                    postImage: widget._file,
                    caption: caption.text,
                    location: location.text,
                  );
                  setState(() {
                    islooding = false;
                  });
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Share',
                  style: TextStyle(color: Colors.blue, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
          child: islooding
              ? Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ))
              : Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          image: DecorationImage(
                            image: FileImage(widget._file),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 280,
                        height: 60,
                        child: TextField(
                          controller: caption,
                          decoration: const InputDecoration(
                            hintText: 'Write a caption ...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: 280,
                    height: 30,
                    child: TextField(
                      controller: location,
                      decoration: const InputDecoration(
                        hintText: 'Add location',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
