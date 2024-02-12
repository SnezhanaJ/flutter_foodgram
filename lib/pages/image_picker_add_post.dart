import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'add_post_text_page.dart';

class InstagramMediaPicker extends StatefulWidget {
  const InstagramMediaPicker({Key? key}) : super(key: key);

  @override
  _InstagramMediaPickerState createState() => _InstagramMediaPickerState();
}

class _InstagramMediaPickerState extends State<InstagramMediaPicker> {
  XFile? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foodgram'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddPostTextScreen(File(_selectedImage!.path)),
                  ));
                },
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (_selectedImage != null) // Show selected image preview
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Image.file(
                        File(_selectedImage!.path),
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width * 0.9, // Make it square
                      ),
                    ),
                  ),
                if(_selectedImage!=null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedImage = null; // Clear selected image
                        });
                      },
                      icon: Icon(Icons.close),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showImageSourceOptions(context);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add_box_rounded),
      ),
    );
  }

  Future<void> _showImageSourceOptions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _loadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _loadImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadImage(ImageSource source) async {
    final XFile? image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }
}

