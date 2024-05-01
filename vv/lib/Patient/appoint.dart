// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:signalr_core/signalr_core.dart';
// import 'package:vv/utils/token_manage.dart'; // Ensure this import is correct for your project
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class SignalRWidget extends StatefulWidget {
//   @override
//   _SignalRWidgetState createState() => _SignalRWidgetState();
// }

// class _SignalRWidgetState extends State<SignalRWidget> {
//   late HubConnection appointmentHubConnection;
//   String action = '';
//   String appointmentId = '';
//   String date = '';
//   String location = '';
//   String notes = '';
//   String familyName = '';
//   bool canDeleted = false;

//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   @override
//   void initState() {
//     super.initState();
//     initializeConnection();
//     initializeNotifications();
//   }

//   void initializeConnection() async {
//     appointmentHubConnection = HubConnectionBuilder()
//         .withUrl(
//           'https://electronicmindofalzheimerpatients.azurewebsites.net/hubs/Appointment',
//           HttpConnectionOptions(
//             accessTokenFactory: () async => await TokenManager.getToken(),
//             logging: (level, message) => print('SignalR log: $message'),
//           ),
//         )
//         .withAutomaticReconnect()
//         .build();

//     appointmentHubConnection.onclose((error) {
//       print('Connection Closed. Error: $error');
//       setState(() {});
//     });

//     await startConnection();
//     setupListener();
//   }

//   void initializeNotifications() {
//     var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

//     var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
     
//     );
//     flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   Future<void> startConnection() async {
//     try {
//       await appointmentHubConnection.start();
//       print('Connection started!');
//     } catch (e) {
//       print('Error starting connection: $e');
//       setState(() {});
//     }
//   }

//   void setupListener() {
//     appointmentHubConnection.on('ReceiveAppointment', (arguments) {
//       print('Raw arguments: $arguments');
//       if (arguments != null && arguments.length >= 2) {
//         setState(() {
//           action = arguments[0] as String;
//           try {
//             Map<String, dynamic> appointmentData = json.decode(arguments[1]);
//             appointmentId = appointmentData['appointmentId'] ?? '';
//             date = appointmentData['date'] ?? '';
//             location = appointmentData['location'] ?? '';
//             notes = appointmentData['notes'] ?? '';
//             familyName = appointmentData['familyNameWhoCreatedAppointment'] ?? '';
//             canDeleted = appointmentData['canDeleted'] ?? false;

//             _showNotification('New Appointment', _buildNotificationBody());
//           } catch (e) {
//             print('Error decoding JSON: $e');
//           }
//         });
//       } else {
//         print('Invalid or null arguments received');
//       }
//     });
//   }

//   Future<void> _showNotification(String title, String body) async {
//     var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'your_channel_id',
//       'your_channel_name',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     var platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
      
//     );
//     await flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       platformChannelSpecifics,
//       payload: 'New Notification',
//     );
//   }

//   String _buildNotificationBody() {
//     return '''
//       Appointment ID: $appointmentId
//       Date: $date
//       Location: $location
//       Notes: $notes
//       Family Name: $familyName
//       Can Deleted: $canDeleted
//     ''';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('SignalR Updates'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text('Action: $action'),
//             SizedBox(height: 20),
//             Text('Appointment ID: $appointmentId'),
//             Text('Date: $date'),
//             Text('Location: $location'),
//             Text('Notes: $notes'),
//             Text('Family Name: $familyName'),
//             Text('Can Deleted: $canDeleted'),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     stopConnection();
//     super.dispose();
//   }

//   Future<void> stopConnection() async {
//     if (appointmentHubConnection != null) {
//       await appointmentHubConnection.stop();
//       print('Connection stopped!');
//     }
//   }
// }
