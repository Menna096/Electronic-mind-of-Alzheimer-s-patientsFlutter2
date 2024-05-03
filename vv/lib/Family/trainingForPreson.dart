import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ImageItem {
  XFile file;
  bool isVisible;

  ImageItem({required this.file, this.isVisible = true});
}

class UploadImagesPagePerson extends StatefulWidget {
  final String fullName;
  final String phoneNumber;
  final String relation;
  final double latitude;
  final double longitude;
  final String description;

  UploadImagesPagePerson({
    required this.fullName,
    required this.phoneNumber,
    required this.relation,
    required this.latitude,
    required this.longitude,
    required this.description,
  });

  @override
  _UploadImagesPagePersonState createState() => _UploadImagesPagePersonState();
}

class _UploadImagesPagePersonState extends State<UploadImagesPagePerson> {
  final ImagePicker _picker = ImagePicker();
  List<ImageItem> _images = [];

  Future<void> _pickImage({int? replaceIndex}) async {
    if (_images.length < 5) {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          if (replaceIndex != null) {
            _images[replaceIndex] = ImageItem(file: image);
          } else {
            _images.add(ImageItem(file: image));
          }
        });
      }
    } else {
      // You may want to show a message here indicating that only five images are allowed.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Images'),
      ),
      body: Column(
        children: <Widget>[
          if (_images.length < 5)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () => _pickImage(),
                child: Text('Add Image ${_images.length + 1}'),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0), // Adjust vertical spacing here
                  child: ListTile(
                    leading: Container(
                      height: 100,
                      width: 100,
                      child: Image.file(File(_images[index].file.path),
                          fit: BoxFit.cover),
                    ),
                    title: Text('Image ${index + 1}'),
                    trailing: IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: () => _pickImage(replaceIndex: index),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_images.length == 5)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Pass captured images back to the previous screen
                  Navigator.pop(
                      context, _images.map((e) => File(e.file.path)).toList());
                },
                child: Text('Next'),
              ),
            ),
        ],
      ),
    );
  }
}
