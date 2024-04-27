import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vv/Patient/mainpagepatient/vediooooo/details.dart';
import 'package:vv/Patient/mainpagepatient/vediooooo/secret_file.dart';
import 'package:vv/Patient/mainpagepatient/vediooooo/vedio.dart';
import 'package:vv/api/login_api.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:geolocator/geolocator.dart';

class SecretFilePage extends StatefulWidget {
  @override
  _SecretFilePageState createState() => _SecretFilePageState();
}

class _SecretFilePageState extends State<SecretFilePage> {
  List<dynamic> secretFiles = [];
  final Dio dio = Dio();
  late HubConnection _connection;
  Timer? _locationTimer; // Initialize Dio // Create Dio Instance

  @override
  void initState() {
    super.initState();
     initializeSignalR(); 
    fetchSecretFiles();
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

  fetchSecretFiles() async {
    try {
      var response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetSecretFile');
      if (response.statusCode == 200) {
        setState(() {
          secretFiles = response.data['secretFiles'];
        });
      } else {
        // Handle error
        print(
            'Failed to load secret files with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Secret Files'),
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
            itemCount: secretFiles.length,
            itemBuilder: (context, index) {
              var file = secretFiles[index];
              if (!file['needToConfirm']) {
                return ListTile(
                    title: Text(file['fileName']),
                    subtitle: Text(file['file_Description']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreenSecret(
                            url: file['documentUrl'],
                            fileType: file['documentExtension'],
                          ),
                        ),
                      );
                    });
              } else {
                return ListTile(
                  title: Text(file['fileName']),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoCaptureScreen(),
                    ),
                  ),
                );
              }
            },
          ),
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: FloatingActionButton(
              onPressed: () {
                // Navigate to FilePage screen when upload button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FileUploadPage(),
                  ),
                );
              },
              child: Icon(Icons.file_upload),
            ),
          ),
        ],
      ),
    );
  }
}
