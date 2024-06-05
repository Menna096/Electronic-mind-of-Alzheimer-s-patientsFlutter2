import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// class Appointment {
//   String id;
//   String date;
//   String location;
//   String notes;
//   String familyName;
//   bool canBeDeleted;

//   Appointment({
//     required this.id,
//     required this.date,
//     required this.location,
//     required this.notes,
//     required this.familyName,
//     required this.canBeDeleted,
//   });

//   factory Appointment.fromJson(Map<String, dynamic> json) {
//     return Appointment(
//       id: json['AppointmentId'] ?? '',
//       date: json['Date'] ?? '',
//       location: json['Location'] ?? '',
//       notes: json['Notes'] ?? '',
//       familyName: json['FamilyNameWhoCreatedAppointemnt'] ?? '',
//       canBeDeleted: json['canBeDeleted'] ?? false,
//     );
//   }
// }

// class SignalRWidget extends StatefulWidget {
//   @override
//   _SignalRWidgetState createState() => _SignalRWidgetState();
// }

// class _SignalRWidgetState extends State<SignalRWidget> {
//   late HubConnection appointmentHubConnection;
//   List<Appointment> appointments = [];

//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

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
//     var initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//     );

//     flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onDidReceiveNotificationResponse:
//             (NotificationResponse response) async {
//       String? payload = response.payload;
//       print('Notification payload: $payload');
//       if (payload != null) {
//         Appointment? appointment =
//             appointments.firstWhere((appointment) => appointment.id == payload,
//                 orElse: () => Appointment(
//                       id: '',
//                       date: '',
//                       location: '',
//                       notes: '',
//                       familyName: '',
//                       canBeDeleted: false,
//                     ));
//         print('Appointment found: ${appointment.id}');
//         if (appointment != null && appointment.id.isNotEmpty) {
//           Navigator.of(context).push(MaterialPageRoute(
//               builder: (context) => AppointmentDetailScreen(
//                     appointment: appointment,
//                   )));
//         }
//       }
//     });
//   }

//   Future<void> startConnection() async {
//     try {
//       await appointmentHubConnection.start();
//       print('Connection started!');
//       setState(() {});
//     } catch (e) {
//       print('Error starting connection: $e');
//       setState(() {});
//     }
//   }

//   void setupListener() {
//     appointmentHubConnection.on('ReceiveAppointment', (arguments) {
//       print('Raw arguments: $arguments');
//       if (arguments != null && arguments.length > 1) {
//         setState(() {
//           try {
//             Map<String, dynamic> appointmentData = json.decode(arguments[1]);
//             print('Decoded JSON: $appointmentData');
//             Appointment appointment = Appointment.fromJson(appointmentData);
//             print('Parsed appointment: ${appointment.id}');
//             appointments.add(appointment);
//             _showNotification('New Appointment',
//                 _buildNotificationBody(appointment), appointment.id);
//             _scheduleNotification(appointment);
//           } catch (e) {
//             print('Error decoding JSON: $e');
//           }
//         });
//       } else {
//         print('Invalid or null arguments received');
//       }
//     });
//   }

//   Future<void> _showNotification(
//       String title, String body, String appointmentId) async {
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
//       payload: appointmentId,
//     );
//   }

//   void _scheduleNotification(Appointment appointment) async {
//     try {
//       String timezone = await FlutterTimezone.getLocalTimezone();
//       tz.initializeTimeZones();
//       final location = tz.getLocation(timezone);
//       final scheduledDateTime = tz.TZDateTime.from(
//         DateTime.parse(appointment.date),
//         location,
//       );

//       print('Scheduled DateTime: $scheduledDateTime');
//       var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//         'your_channel_id',
//         'your_channel_name',
//         importance: Importance.max,
//         priority: Priority.high,
//       );
//       var platformChannelSpecifics = NotificationDetails(
//         android: androidPlatformChannelSpecifics,
//       );

//       await flutterLocalNotificationsPlugin.zonedSchedule(
//         0,
//         'Scheduled Appointment',
//         _buildNotificationBody(appointment),
//         scheduledDateTime,
//         platformChannelSpecifics,
//         payload: appointment.id,
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         matchDateTimeComponents: DateTimeComponents.time,
//       );

//       print('Notification scheduled successfully');
//     } catch (e) {
//       print('Error scheduling notification: $e');
//     }
//   }

//   String _buildNotificationBody(Appointment appointment) {
//     return '''
//       Appointment ID: ${appointment.id}
//       Date: ${appointment.date}
//       Location: ${appointment.location}
//       Notes: ${appointment.notes}
//       Family Name: ${appointment.familyName}
//       Can Be Deleted: ${appointment.canBeDeleted}
//     ''';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('SignalR Updates'),
//       ),
//       body: ListView.builder(
//         itemCount: appointments.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text('Appointment ID: ${appointments[index].id}'),
//             subtitle: Text('Date: ${appointments[index].date}'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       AppointmentDetailScreen(appointment: appointments[index]),
//                 ),
//               );
//             },
//           );
//         },
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

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;

  AppointmentDetailScreen({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Appointment ID: ${appointment.id}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Date: ${appointment.date}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Location: ${appointment.location}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Notes: ${appointment.notes}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Family Name: ${appointment.familyName}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Can Be Deleted: ${appointment.canBeDeleted}',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
