import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:math';


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
          title: const Text('Confirm Upload'),
          content: const Text('Are you sure you want to send this video?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Send'),
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

      // Include the authorization token in the headers
      dio.options.headers['Authorization'] =
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI2YWFkYzQ0Ny0zM2Q0LTRmODItOTk3Mi1jNzAwYzNkOGU2NGIiLCJlbWFpbCI6InBhdGllbnQyMjk5MDBAZ21haWwuY29tIiwiRnVsbE5hbWUiOiJtZW5uYSIsIlBob25lTnVtYmVyIjoiMzM1NDMzMiIsInVpZCI6IjZmYmE4ZDg4LTk4ODAtNGZlMC1hODAwLWU5NjIyMDY1ZWNiOSIsIlVzZXJBdmF0YXIiOiJodHRwczovL2VsZWN0cm9uaWNtaW5kb2ZhbHpoZWltZXJwYXRpZW50cy5henVyZXdlYnNpdGVzLm5ldC9Vc2VyIEF2YXRhci82ZmJhOGQ4OC05ODgwLTRmZTAtYTgwMC1lOTYyMjA2NWVjYjlfNTQ0YTdhNTUtOTQ4Yi00MGVjLTkxMjMtODMxMWI0OTU3NTdiLmpwZyIsInJvbGVzIjoiUGF0aWVudCIsImV4cCI6MTcyMTAxNTEwNCwiaXNzIjoiQXJ0T2ZDb2RpbmciLCJhdWQiOiJBbHpoZWltYXJBcHAifQ.0b_MxqQnpJaSBi9QgHZX9RCx0IVRb0YYwA4kg-vIGN8';

      var response = await dio.post(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/AskToSeeSecretFile',
        data: formData,
      );

      if (response.statusCode == 200) {
        print('Video uploaded successfully');
        // Display a SnackBar with the success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video uploaded successfully'),
          ),
        );
      } else {
        print('Failed to upload video');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload video,Try Again'),
          ),
        );
      }
    } catch (e) {
      print('Error uploading video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading video: $e'),
        ),
      );
    }
  }

  // Function to generate random text
  void generateRandomText() {
    setState(() {
      // Generate a random integer between 0 and 100
      int randomNumber = Random().nextInt(101);
      randomText = 'Random Number: $randomNumber'; // Set the random text
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Capture Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _addMedia();
              },
              child: const Text('Capture Video'),
            ),
            const SizedBox(height: 20), // Add some space between the buttons
            ElevatedButton(
              onPressed: () {
                generateRandomText(); // Call the function to generate random text
              },
              child: const Text('Generate Random Text'),
            ),
            const SizedBox(height: 20), // Add some space between the buttons
            Text(
              randomText, // Display the random text
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}