import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vv/faceid.dart';

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

  const UploadImagesPagePerson({super.key, 
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
  final List<ImageItem> _images = [];
  int _currentImageIndex = 0;

  final List<String> _instructionImages = [
    'images/1.jpg',
    'images/2.jpg',
    'images/3.jpg',
    'images/4.jpg',
    'images/5.jpg',
  ];

  final List<String> _imageInstructions = [
    "Directly facing the camera, eyes looking straight ahead",
    "The head turned slightly so the right side is more visible than the left",
    "Turn your head to the right until your profile aligns with the camera",
    "The head turned slightly so the left side is more visible than the right",
    "Turn your head to the left until your profile aligns with the camera",
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _showInstructionMessage());
  }

  Future<void> _showInstructionMessage() async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Instructions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'These images help the patient recognize you better. Please follow the instructions and upload five images.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showInstructionDialog({int? replaceIndex}) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          title: Text('Instructions for Image ${_currentImageIndex + 1}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _imageInstructions[_currentImageIndex],
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Image.asset(
                  _instructionImages[_currentImageIndex],
                  height: 200,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Capture Image'),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: AnimatedBackground(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  if (_currentImageIndex < 5)
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
                        horizontal: 20.0, vertical: 8.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Image.file(
                            File(_images[index].file.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          'Image ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () =>
                              _showInstructionDialog(replaceIndex: index),
                        ),
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
                    Navigator.pop(context,
                        _images.map((e) => File(e.file.path)).toList());
                  },
                  child: const Text('Next'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
