import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/faceid.dart';

class ImageItem {
  XFile file;
  bool isVisible;

  ImageItem({required this.file, this.isVisible = true});
}

class UploadImagesPage extends StatefulWidget {
  const UploadImagesPage({super.key});

  @override
  _UploadImagesPageState createState() => _UploadImagesPageState();
}

class _UploadImagesPageState extends State<UploadImagesPage> {
  final ImagePicker _picker = ImagePicker();
  final List<ImageItem> _images = [];
  int _currentImageIndex = 0;
  bool _isLoading = false;

  final List<String> _instructionImages = [
    'images/1.jpg',
    'images/2.jpg',
    'images/3.jpg',
    'images/4.jpg',
    'images/5.jpg',
  ];

  final List<String> _imageInstructions = [
    'instruction_1'.tr(),
    'instruction_2'.tr(),
    'instruction_3'.tr(),
    'instruction_4'.tr(),
    'instruction_5'.tr(),
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
                Text(
                  'Instructions'.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'These images help the patient recognize you better. Please follow the instructions and upload five images'
                      .tr(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'.tr()),
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
              child: Text('Capture Image'.tr()),
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
      body: Stack(
        children: [
          AnimatedBackground(
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
                          child: Text(
                            'capture_image'.tr(
                                args: [(_currentImageIndex + 1).toString()]),
                          ),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                        _uploadImages();
                      },
                      child: Text('Add'.tr()),
                    ),
                  ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: SpinKitFadingCircle(
                  color: Colors.white,
                  size: 50.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _uploadImages() async {
    setState(() {
      _isLoading = true;
    });

    var formData = FormData();
    for (var imageItem in _images) {
      formData.files.add(MapEntry(
        'TrainingImages',
        await MultipartFile.fromFile(imageItem.file.path,
            filename: imageItem.file.name),
      ));
    }

    try {
      var response = await DioService().dio.post(
            'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/FamilyTrainingImages',
            data: formData,
          );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Upload successful".tr()),
          backgroundColor: Colors.green,
        ));

        // Navigate to MainPageFamily on success
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainPageFamily()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error uploading images".tr()),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error uploading images".tr()),
        backgroundColor: Colors.red,
      ));
      print('Error uploading images: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
