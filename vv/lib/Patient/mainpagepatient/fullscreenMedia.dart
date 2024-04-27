import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:vv/models/media_item.dart';
import 'package:vv/models/media_patient.dart';
import 'package:vv/widgets/background.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:geolocator/geolocator.dart';

class FullScreenViewerpatient extends StatefulWidget {
  final MediaItempatient mediaItem;

  FullScreenViewerpatient({required this.mediaItem});

  @override
  _FullScreenViewerpatientState createState() =>
      _FullScreenViewerpatientState();
}

class _FullScreenViewerpatientState extends State<FullScreenViewerpatient> {
  VideoPlayerController? _controller;
 late HubConnection _connection;
  Timer? _locationTimer; // Initialize Dio
  @override
  void initState() {
    super.initState();
     initializeSignalR();
    if (widget.mediaItem.type == MediaType.video &&
        widget.mediaItem.isNetwork) {
      _controller = VideoPlayerController.network(widget.mediaItem.path)
        ..initialize().then((_) {
          setState(() {});
          _controller!.play();
        });
    }
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
    _controller?.dispose();
    super.dispose();
  }

  String formatDateString(String dateString) {
    try {
      final DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      print("Error parsing date: $e");
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Background(
        SingleChildScrollView: null,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.mediaItem.type == MediaType.image)
                widget.mediaItem.isNetwork
                    ? Image.network(widget.mediaItem.path)
                    : Image.file(File(widget.mediaItem.path)),
              if (widget.mediaItem.type == MediaType.video)
                _controller != null && _controller!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                    : CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.mediaItem.description,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                "Uploaded on: ${formatDateString(widget.mediaItem.uploadedDate)}", // Formatted date
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                "Uploaded by: ${widget.mediaItem.uploaderFamilyName}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
