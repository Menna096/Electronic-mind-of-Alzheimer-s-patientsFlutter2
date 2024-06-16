import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  int _currentImageIndex = 0;

  final List<String> _instructionImages = [
    'images/1.jpg',
    'images/2.jpg',
    'images/3.jpg',
    'images/4.jpg',
    'images/5.jpg',
  ];

  Future<void> _showInstructionDialog({int? replaceIndex}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to dismiss dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions for Image ${_currentImageIndex + 1}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Image.asset(
                  _instructionImages[_currentImageIndex],
                  height: 200,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Capture Image'),
              onPressed: () async {
                final XFile? image =
                    await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    if (replaceIndex != null) {
                      _images[replaceIndex] = ImageItem(file: image);
                    } else {
                      _images.add(ImageItem(file: image));
                    }
                    _currentImageIndex++;
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Images'),
      ),
      body: Column(
        children: <Widget>[
          if (_currentImageIndex < 5)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _showInstructionDialog(),
                    child: Text('Capture Image ${_currentImageIndex + 1}'),
                  ),
                ],
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
                      onPressed: () =>
                          _showInstructionDialog(replaceIndex: index),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_currentImageIndex == 5)
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
