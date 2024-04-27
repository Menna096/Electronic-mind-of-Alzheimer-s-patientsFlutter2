import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vv/api/dio_ser.dart';

import 'package:vv/models/media_item.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:vv/widgets/background.dart';

class DescriptionScreen extends StatefulWidget {
  final String mediaPath;
  final MediaType type;
  late HubConnection _connection;
  String _currentLocation = "Waiting for location...";
  bool _locationReceived = false;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  void initState() {
    initializeSignalR();
    initNotifications();
  }

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {
    if (notificationResponse.payload != null) {
      var data = notificationResponse.payload!.split(',');
      double latitude = double.parse(data[0]);
      double longitude = double.parse(data[1]);
      _launchGoogleMaps(latitude, longitude);
    }
  }

  Future<void> initializeSignalR() async {
    _connection = HubConnectionBuilder()
        .withUrl(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/hubs/GPS',
          HttpConnectionOptions(
            accessTokenFactory: () async => await TokenManager.getToken(),
            logging: (level, message) => print(message),
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection.on('ReceiveGPSToFamilies', (arguments) {
      if (arguments != null && arguments.length >= 2) {
        double latitude = arguments[0];
        double longitude = arguments[1];

        _showNotification(latitude, longitude);
        print('Location received: Latitude $latitude, Longitude $longitude');
      }
    });

    try {
      await _connection.start();
      print('SignalR connection established.');
    } catch (e) {
      print('Failed to start SignalR connection: $e');
    }
  }

  Future<void> _showNotification(double latitude, double longitude) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _notificationsPlugin.show(
      0,
      'New Location Received',
      'Latitude: $latitude, Longitude: $longitude',
      platformChannelSpecifics,
      payload: '$latitude,$longitude',
    );
  }

  Future<void> _launchGoogleMaps(double latitude, double longitude) async {
    final url = 'geo:0,0?q=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  DescriptionScreen({required this.mediaPath, required this.type});

  @override
  _DescriptionScreenState createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen> {
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveMedia() async {
    MediaService mediaService = MediaService();
    bool uploadSuccessful = await mediaService.uploadFile(
        widget.mediaPath, _descriptionController.text, widget.type);

    if (uploadSuccessful) {
      // Create a new MediaItem with the provided path, description, and type
      final newMediaItem = MediaItem(
        path: widget.mediaPath,
        description: _descriptionController.text,
        type: widget.type,
      );

      // Return to the previous screen with the new media item
      Navigator.pop(context, newMediaItem);
    } else {
      // Handle upload failure (e.g., show an error message)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add picture or video')),
      body: Background(
        SingleChildScrollView: null,
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 100,
              backgroundImage: FileImage(File(widget.mediaPath)),
              child: widget.type == MediaType.video
                  ? Icon(Icons.play_circle_fill, size: 100)
                  : null,
            ),
            SizedBox(height: 20),
            Text('Enter a simple description about the picture/video'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Description',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _saveMedia,
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}