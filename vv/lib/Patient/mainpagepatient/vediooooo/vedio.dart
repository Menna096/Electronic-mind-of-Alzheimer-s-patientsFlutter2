import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:math';

import 'package:signalr_core/signalr_core.dart';
import 'package:vv/utils/token_manage.dart';

class VideoCaptureScreen extends StatefulWidget {
  @override
  _VideoCaptureScreenState createState() => _VideoCaptureScreenState();
}

class _VideoCaptureScreenState extends State<VideoCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  late Dio dio;
  late HubConnection _connection;
  Timer? _locationTimer; // Initialize Dio

  String randomText = ''; // Initialize the variable to hold random text

  @override
  void initState() {
    super.initState();
    dio = Dio();
    initializeSignalR(); // Initialize Dio instance
  }

  Future<void> initializeSignalR() async {
    final token = await TokenManager.getToken();
    _connection = HubConnectionBuilder()
        .withUrl(
      'https://electronicmindofalzheimerpatients.azurewebsites.net/hubs/GPS',
      HttpConnectionOptions(
        accessTokenFactory: () => Future.value(token),
        logging: (level, message) => print(message),
      ),
    )
        .withAutomaticReconnect(
            [0, 2000, 10000, 30000]) // Configuring automatic reconnect
        .build();

    _connection.onclose((error) async {
      print('Connection closed. Error: $error');
      // Optionally initiate a manual reconnect here if automatic reconnect is not sufficient
      await reconnect();
    });

    try {
      await _connection.start();
      print('SignalR connection established.');
      // Start sending location every minute after the connection is established
      _locationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        sendCurrentLocation();
      });
    } catch (e) {
      print('Failed to start SignalR connection: $e');
      await reconnect();
    }
  }

  Future<void> reconnect() async {
    int retryInterval = 1000; // Initial retry interval to 5 seconds
    while (_connection.state != HubConnectionState.connected) {
      await Future.delayed(Duration(milliseconds: retryInterval));
      try {
        await _connection.start();
        print("Reconnected to SignalR server.");
        return; // Exit the loop if connected
      } catch (e) {
        print("Reconnect failed: $e");
        retryInterval = (retryInterval < 1000)
            ? retryInterval + 1000
            : 1000; // Increase retry interval, cap at 1 seconds
      }
    }
  }

  Future<void> sendCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await _connection.invoke('SendGPSToFamilies',
          args: [position.latitude, position.longitude]);
      print('Location sent: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel(); // Cancel the timer when the widget is disposed
    _connection.stop(); // Optionally stop the connection
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
          title: Text('Confirm Upload'),
          content: Text('Are you sure you want to send this video?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Send'),
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
          SnackBar(
            content: Text('Video uploaded successfully'),
          ),
        );
      } else {
        print('Failed to upload video');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
        title: Text('Video Capture Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _addMedia();
              },
              child: Text('Capture Video'),
            ),
            SizedBox(height: 20), // Add some space between the buttons
            ElevatedButton(
              onPressed: () {
                generateRandomText(); // Call the function to generate random text
              },
              child: Text('Generate Random Text'),
            ),
            SizedBox(height: 20), // Add some space between the buttons
            Text(
              randomText, // Display the random text
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}