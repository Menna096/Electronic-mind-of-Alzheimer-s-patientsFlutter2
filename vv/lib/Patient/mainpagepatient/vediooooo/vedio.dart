import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import 'package:vv/api/login_api.dart';

class VideoCaptureScreen extends StatefulWidget {
  const VideoCaptureScreen({super.key});

  @override
  _VideoCaptureScreenState createState() => _VideoCaptureScreenState();
}

class _VideoCaptureScreenState extends State<VideoCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  late Dio dio;

  String randomText = ''; // Initialize the variable to hold random text

  @override
  void initState() {
    super.initState();
    dio = Dio();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _addMedia() async {
    final XFile? pickedFile = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 60),
    );

    if (pickedFile != null) {
      _showUploadDialog(pickedFile.path);
    }
  }

  void _showUploadDialog(String filePath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirm Upload'.tr()),
          content: Text('Are you sure you want to send this video?'.tr()),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'.tr()),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Send'.tr()),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _uploadFile(filePath);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadFile(String filePath) async {
    try {
      FormData formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(filePath),
      });

      var response = await DioService().dio.post(
            'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/AskToSeeSecretFile',
            data: formData,
          );

      if (response.statusCode == 200) {
        print('Video uploaded successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video uploaded successfully'.tr()),
          ),
        );
      } else {
        print('Failed to upload video');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload video, Try Again'.tr()),
          ),
        );
      }
    } catch (e) {
      print('Error uploading video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading video'.tr()),
        ),
      );
    }
  }

  // Function to generate random text
  void generateRandomText() {
    setState(() {
      int randomNumber = Random().nextInt(101);
      randomText = ' $randomNumber';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Capture'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _addMedia,
                icon: const Icon(Icons.videocam),
                label: Text('Capture Video'.tr()),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: generateRandomText,
                icon: const Icon(Icons.shuffle),
                label: Text('Generate Random Text'.tr()),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                randomText,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
