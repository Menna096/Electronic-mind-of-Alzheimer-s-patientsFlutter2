import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:vv/widgets/background.dart';
import 'package:vv/widgets/mainfamily.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MainPageFamily extends StatefulWidget {
  const MainPageFamily({super.key});

  @override
  _MainPageFamilyState createState() => _MainPageFamilyState();
}

class _MainPageFamilyState extends State<MainPageFamily> {
  late HubConnection _connection;
  String _currentLocation = "Waiting for location...";
  bool _locationReceived = false;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
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
        setState(() {
          _currentLocation = 'Latitude: $latitude, Longitude: $longitude';
          _locationReceived = true;
        });
        _showNotification(latitude, longitude);
        print('Location received: Latitude $latitude, Longitude $longitude');
      }
    });

    try {
      await _connection.start();
      print('SignalR connection established.');
    } catch (e) {
      print('Failed to start SignalR connection: $e');
      setState(() {
        _currentLocation = 'Error starting connection: $e';
      });
    }
  }

  Future<void> _showNotification(double latitude, double longitude) async {
     AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      sound: RawResourceAndroidNotificationSound('sound.m4a'.split('.').first),
    );
     NotificationDetails platformChannelSpecifics =
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

  @override
  void dispose() {
    _connection.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 84, 134, 235),
      ),
      drawer: buildDrawer(context),
      resizeToAvoidBottomInset: false,
      body: Background(
        SingleChildScrollView: null,
        child: buildFamily(),
      ),
    );
  }
}
