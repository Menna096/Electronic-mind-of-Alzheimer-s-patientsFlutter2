import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SignalRWidget extends StatefulWidget {
  @override
  _SignalRWidgetState createState() => _SignalRWidgetState();
}

class _SignalRWidgetState extends State<SignalRWidget> {
  final appointmentHubConnection = HubConnectionBuilder()
      .withUrl(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/hubs/Appointment',
        HttpConnectionOptions(
          accessTokenFactory: () async => await TokenManager.getToken(),
          logging: (level, message) => print(message),
        ),
      )
      .withAutomaticReconnect()
      .build();

  String action = '';
  String appointmentData = '';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    startConnection();
    setupListener();
  }

  Future<void> _showNotification(String title, String jsonString) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id', // Change this to your own channel ID
      'your_channel_name', // Change this to your own channel name
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      jsonString, // Use the JSON string representation in the notification body
      platformChannelSpecifics,
      payload: 'New Notification',
    );
  }

  void startConnection() async {
    try {
      await appointmentHubConnection.start();
      print('Connection started!');
    } catch (e) {
      print('Error starting connection: $e');
    }
  }

  void setupListener() {
    appointmentHubConnection.on('ReceiveAppointment', (arguments) {
      print('Received arguments: $arguments');
      if (arguments!.length >= 2) {
        setState(() {
          action = arguments[0];
          print('Action: $action');
          appointmentData = arguments[1];
          print('Appointment Data: $appointmentData');
          _showNotification('New Appointment', appointmentData);
        });
      } else {
        print('Invalid arguments received');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SignalR Updates'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Action: $action'),
            Text('Appointment Data: $appointmentData'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    stopConnection();
    super.dispose();
  }

  void stopConnection() async {
    await appointmentHubConnection.stop();
    print('Connection stopped!');
  }
}
