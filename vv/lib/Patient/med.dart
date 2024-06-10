import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Reminder {
  String MedicationId;
  String Medication_Name;
  String Dosage;
  int medicineType;
  int Repeater;
  DateTime startDate;
  DateTime endDate;

  Reminder({
    required this.MedicationId,
    required this.Medication_Name,
    required this.Dosage,
    required this.medicineType,
    required this.Repeater,
    required this.startDate,
    required this.endDate,
  });

  // Factory method to create a Reminder object from JSON
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      MedicationId: json['MedicationId'],
      Medication_Name: json['Medication_Name'],
      Dosage: json['Dosage'],
      medicineType: json['MedcineType'],
      Repeater: json['Repeater'],
      startDate: DateTime.parse(json['StartDate']),
      endDate: DateTime.parse(json['EndDate']),
    );
  }
}

class MedicinesPage extends StatefulWidget {
  @override
  _MedicinesPageState createState() => _MedicinesPageState();
}

class _MedicinesPageState extends State<MedicinesPage> {
  List<dynamic> medicines = [];
  bool isLoading = true;
  String errorMessage = '';
  List<Reminder> reminders = [];
  late HubConnection medicineHubConnection;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    fetchMedicines();
    // initializeConnectionmedicine();
    // initializeNotificationsMedicine();
  }

  Future<void> fetchMedicines() async {
    String url =
        'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetAllMedicines';

    try {
      Response response = await DioService().dio.get(url);
      setState(() {
        medicines = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching medicines: $e';
        isLoading = false;
      });
    }
  }

  // void initializeConnectionmedicine() async {
  //   medicineHubConnection = HubConnectionBuilder()
  //       .withUrl(
  //         'https://electronicmindofalzheimerpatients.azurewebsites.net/hubs/medicineReminder',
  //         HttpConnectionOptions(
  //           accessTokenFactory: () async => await TokenManager.getToken(),
  //           logging: (level, message) => print('SignalR log: $message'),
  //         ),
  //       )
  //       .withAutomaticReconnect()
  //       .build();

  //   medicineHubConnection.onclose((error) {
  //     print('Connection Closed. Error: $error');
  //     setState(() {});
  //   });

  //   await startConnectionMedicine();
  //   setupListenerMedicine();
  // }

  // void initializeNotificationsMedicine() {
  //   var initializationSettingsAndroid =
  //       AndroidInitializationSettings('@mipmap/ic_launcher');

  //   var initializationSettings = InitializationSettings(
  //     android: initializationSettingsAndroid,
  //   );

  //   flutterLocalNotificationsPlugin.initialize(initializationSettings,
  //       onDidReceiveNotificationResponse:
  //           (NotificationResponse response) async {
  //     String? payload = response.payload;
  //     print('Notification payload: $payload');
  //     if (payload != null) {
  //       Reminder? reminder =
  //           reminders.firstWhere((reminder) => reminder.MedicationId == payload,
  //               orElse: () => Reminder(
  //                     MedicationId: '',
  //                     Medication_Name: '',
  //                     Dosage: '',
  //                     medicineType: 0,
  //                     Repeater: 0,
  //                     startDate: DateTime(1970, 1, 1),
  //                     endDate: DateTime(1970, 1, 1),
  //                   ));
  //       print('Appointment found: ${reminder.MedicationId}');
  //       // if (appointment != null && appointment.id.isNotEmpty) {
  //       //   Navigator.of(context).push(MaterialPageRoute(
  //       //       builder: (context) => AppointmentDetailScreen(
  //       //             appointment: appointment,
  //       //           )));
  //       // }
  //     }
  //   });
  // }

  // Future<void> startConnectionMedicine() async {
  //   try {
  //     await medicineHubConnection.start();
  //     print('Connection started!');
  //     setState(() {});
  //   } catch (e) {
  //     print('Error starting connection: $e');
  //     setState(() {});
  //   }
  // }

  // void setupListenerMedicine() {
  //   medicineHubConnection.on('ReceiveMedicineReminder', (arguments) {
  //     print('Raw arguments: $arguments');
  //     if (arguments != null) {
  //       setState(() {
  //         try {
  //           Map<String, dynamic> reminderData = json.decode(arguments[1]);
  //           print('Decoded JSON: $reminderData');
  //           Reminder reminder = Reminder.fromJson(reminderData);
  //           print('Parsed appointment: ${reminder.MedicationId}');
  //           reminders.add(reminder);
  //           _showNotificationMedicine('New Medicine',
  //               _buildNotificationBody(reminder), reminder.MedicationId);
  //           _scheduleNotification(reminder);
  //         } catch (e) {
  //           print('Error decoding JSON: $e');
  //         }
  //       });
  //     } else {
  //       print('Invalid or null arguments received');
  //     }
  //   });
  // }

  // Future<void> _showNotificationMedicine(
  //     String title, String body, String appointmentId) async {
  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //     'your_channel_id',
  //     'your_channel_name',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //   var platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //   );
  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     title,
  //     body,
  //     platformChannelSpecifics,
  //     payload: appointmentId,
  //   );
  // }

  // void _scheduleNotification(Reminder reminder) async {
  //   try {
  //     String timezone = await FlutterTimezone.getLocalTimezone();
  //     tz.initializeTimeZones();
  //     final location = tz.getLocation(timezone);
  //     final scheduledDateTime = tz.TZDateTime.from(
  //       reminder.startDate,
  //       location,
  //     );

  //     print('Scheduled DateTime: $scheduledDateTime');
  //     var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //       'your_channel_id',
  //       'your_channel_name',
  //       importance: Importance.max,
  //       priority: Priority.high,
  //     );
  //     var platformChannelSpecifics = NotificationDetails(
  //       android: androidPlatformChannelSpecifics,
  //     );

  //     await flutterLocalNotificationsPlugin.zonedSchedule(
  //       0,
  //       'Scheduled Appointment',
  //       _buildNotificationBody(reminder),
  //       scheduledDateTime,
  //       platformChannelSpecifics,
  //       payload: reminder.MedicationId,
  //       androidAllowWhileIdle: true,
  //       uiLocalNotificationDateInterpretation:
  //           UILocalNotificationDateInterpretation.absoluteTime,
  //       matchDateTimeComponents: DateTimeComponents.time,
  //     );

  //     print('Notification scheduled successfully');
  //   } catch (e) {
  //     print('Error scheduling notification: $e');
  //   }
  // }

  // String _buildNotificationBody(Reminder reminder) {
  //   return '''
  //     Appointment ID: ${reminder.MedicationId}
  //     Date: ${reminder.Medication_Name}
  //     Location: ${reminder.medicineType}
  //     Notes: ${reminder.Dosage}
  //     Family Name: ${reminder.startDate}
  //     Can Be Deleted: ${reminder.endDate}
  //   ''';
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicines List'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    var medicine = medicines[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Medication Name: ${medicine['medication_Name']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text('Dosage: ${medicine['dosage']}'),
                            SizedBox(height: 5),
                            Text('Medicine Type: ${medicine['medcineType']}'),
                            SizedBox(height: 5),
                            Text('Repeater: ${medicine['repeater']}'),
                            SizedBox(height: 5),
                            Text('Start Date: ${medicine['startDate']}'),
                            SizedBox(height: 5),
                            Text('End Date: ${medicine['endDate']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class MedicineDetailsPatient extends StatelessWidget {
  final Reminder reminder;

  MedicineDetailsPatient({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Appointment ID: ${reminder.MedicationId}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Date: ${reminder.Medication_Name}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Location: ${reminder.Dosage}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Notes: ${reminder.medicineType}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Family Name: ${reminder.Repeater}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Can Be Deleted: ${reminder.startDate}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Can Be Deleted: ${reminder.endDate}',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
