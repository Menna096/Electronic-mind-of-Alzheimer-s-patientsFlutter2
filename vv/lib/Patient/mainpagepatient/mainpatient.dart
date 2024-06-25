import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:chat_bot/chat/ui/chat_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Notes/views/Notes_view/Notes_view.dart';
import 'package:vv/Patient/appoint.dart';
import 'package:vv/Patient/identifiy.dart';
import 'package:vv/Patient/mainpagepatient/all_families.dart';
import 'package:vv/Patient/mainpagepatient/patient_media.dart';
import 'package:vv/Patient/mainpagepatient/patient_prof.dart';
import 'package:vv/Patient/mainpagepatient/vediooooo/show_sec.dart';
import 'package:vv/Patient/med.dart';
import 'package:vv/daily_task/pages/home/home_page.dart';
import 'package:vv/page/level_select.dart';
import 'package:vv/utils/token_manage.dart';

class Appointment {
  String id;
  String date;
  String location;
  String notes;
  String familyName;
  bool canBeDeleted;

  Appointment({
    required this.id,
    required this.date,
    required this.location,
    required this.notes,
    required this.familyName,
    required this.canBeDeleted,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['AppointmentId'] ?? '',
      date: json['Date'] ?? '',
      location: json['Location'] ?? '',
      notes: json['Notes'] ?? '',
      familyName: json['FamilyNameWhoCreatedAppointemnt'] ?? '',
      canBeDeleted: json['canBeDeleted'] ?? false,
    );
  }
}

class mainpatient extends StatefulWidget {
  const mainpatient({super.key});

  @override
  _mainpatientState createState() => _mainpatientState();
}

class _mainpatientState extends State<mainpatient> {
  
  String? _token;
  String? _photoUrl;
  String? _userName;
  late HubConnection _connection;
  Timer? _locationTimer;
  late HubConnection appointmentHubConnection;
  List<Appointment> appointments = [];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  List<Reminder> reminders = [];
  late HubConnection medicineHubConnection;

  @override
  void initState() {
    super.initState();
    _getDataFromToken();
    initializeSignalR();
    initializeConnection();
    initializeNotifications();
    initializeConnectionmedicine();
    initializeNotificationsMedicine();
  }

  void initializeConnectionmedicine() async {
    medicineHubConnection = HubConnectionBuilder()
        .withUrl(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/hubs/medicineReminder',
          HttpConnectionOptions(
            accessTokenFactory: () async => await TokenManager.getToken(),
            logging: (level, message) => print('SignalR log: $message'),
          ),
        )
        .withAutomaticReconnect()
        .build();

    medicineHubConnection.onclose((error) {
      print('Connection Closed. Error: $error');
      setState(() {});
    });

    await startConnectionMedicine();
    setupListenerMedicine();
  }

  void initializeNotificationsMedicine() {
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (NotificationResponse response) async {
      String? payload = response.payload;
      print('Notification payload: $payload');
      if (payload != null) {
        Reminder? reminder = reminders.firstWhere((reminder) => reminder.MedicationId == payload,
            orElse: () => Reminder(
                  MedicationId: '',
                  Medication_Name: '',
                  Dosage: '',
                  medicineType: 0,
                  Repeater: 0,
                  startDate: DateTime(1970, 1, 1),
                  endDate: DateTime(1970, 1, 1),
                ));
        print('Appointment found: ${reminder.MedicationId}');
        if (reminder != null && reminder.MedicationId.isNotEmpty) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MedicineDetailsPatient(
                    reminder: reminder,
                  )));
        }
      }
    });
  }

  Future<void> startConnectionMedicine() async {
    try {
      await medicineHubConnection.start();
      print('Connection started!');
      setState(() {});
    } catch (e) {
      print('Error starting connection: $e');
      setState(() {});
    }
  }

  void setupListenerMedicine() {
    medicineHubConnection.on('ReceiveMedicineReminder', (arguments) {
      print('Raw arguments: $arguments');
      if (arguments != null) {
        setState(() {
          try {
            Map<String, dynamic> reminderData = json.decode(arguments[1]);
            print('Decoded JSON: $reminderData');
            Reminder reminder = Reminder.fromJson(reminderData);
            print('Parsed appointment: ${reminder.MedicationId}');
            reminders.add(reminder);
            String notificationBody = _buildNotificationBodyMedicine(reminder);
            _showNotificationMedicine('New Medicine Added, See it', notificationBody, reminder.MedicationId);
            _scheduleNotificationMedicine(reminder);
          } catch (e) {
            print('Error decoding JSON: $e');
          }
        });
      } else {
        print('Invalid or null arguments received');
      }
    });
  }

  Future<void> _showNotificationMedicine(String title, String body, String medicationId) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('sound.m4a'.split('.').first),
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: medicationId,
    );
  }

  void _scheduleNotificationMedicine(Reminder reminder) async {
    try {
      String timezone = await FlutterTimezone.getLocalTimezone();
      tz.initializeTimeZones();
      final location = tz.getLocation(timezone);
      final scheduledDateTime = tz.TZDateTime.from(
        reminder.startDate,
        location,
      );

      print('Scheduled DateTime: $scheduledDateTime');
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('sound.m4a'.split('.').first),
      );
      var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Medication Time Now',
        _buildNotificationBodyMedicine(reminder),
        scheduledDateTime,
        platformChannelSpecifics,
        payload: reminder.MedicationId,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('Notification scheduled successfully');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  String _buildNotificationBodyMedicine(Reminder reminder) {
    return 'Medication: ${reminder.Medication_Name}, Dosage: ${reminder.Dosage}';
  }

  void initializeConnection() async {
    appointmentHubConnection = HubConnectionBuilder()
        .withUrl(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/hubs/Appointment',
          HttpConnectionOptions(
            accessTokenFactory: () async => await TokenManager.getToken(),
            logging: (level, message) => print('SignalR log: $message'),
          ),
        )
        .withAutomaticReconnect()
        .build();

    appointmentHubConnection.onclose((error) {
      print('Connection Closed. Error: $error');
      setState(() {});
    });

    await startConnection();
    setupListener();
  }

  void initializeNotifications() {
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (NotificationResponse response) async {
      String? payload = response.payload;
      print('Notification payload: $payload');
      if (payload != null) {
        Appointment? appointment = appointments.firstWhere((appointment) => appointment.id == payload,
            orElse: () => Appointment(
                  id: '',
                  date: '',
                  location: '',
                  notes: '',
                  familyName: '',
                  canBeDeleted: false,
                ));
        print('Appointment found: ${appointment.id}');
        if (appointment != null && appointment.id.isNotEmpty) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AppointmentDetailScreen(
                    appointment: appointment,
                  )));
        }
      }
    });
  }

  Future<void> startConnection() async {
    try {
      await appointmentHubConnection.start();
      print('Connection started!');
      setState(() {});
    } catch (e) {
      print('Error starting connection: $e');
      setState(() {});
    }
  }

  void setupListener() {
    appointmentHubConnection.on('ReceiveAppointment', (arguments) {
      print('Raw arguments: $arguments');
      if (arguments != null && arguments.length > 1) {
        setState(() {
          try {
            Map<String, dynamic> appointmentData = json.decode(arguments[1]);
            print('Decoded JSON: $appointmentData');
            Appointment appointment = Appointment.fromJson(appointmentData);
            print('Parsed appointment: ${appointment.id}');
            appointments.add(appointment);
            _showNotification('New Appointment Added', _buildNotificationBody(appointment), appointment.id);
            _scheduleNotification(appointment);
          } catch (e) {
            print('Error decoding JSON: $e');
          }
        });
      } else {
        print('Invalid or null arguments received');
      }
    });
  }

  Future<void> _showNotification(String title, String body, String appointmentId) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('sound.m4a'.split('.').first),
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: appointmentId,
    );
  }

  void _scheduleNotification(Appointment appointment) async {
    try {
      String timezone = await FlutterTimezone.getLocalTimezone();
      tz.initializeTimeZones();
      final location = tz.getLocation(timezone);
      final scheduledDateTime = tz.TZDateTime.from(
        DateTime.parse(appointment.date),
        location,
      );

      print('Scheduled DateTime: $scheduledDateTime');
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('sound.m4a'.split('.').first),
      );
      var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Appointment Time Now',
        _buildNotificationBody(appointment), // Only notes will be shown
        scheduledDateTime,
        platformChannelSpecifics,
        payload: appointment.id,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('Notification scheduled successfully');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  String _buildNotificationBody(Appointment appointment) {
    return appointment.notes;
  }

  Future<void> _getDataFromToken() async {
    _token = await TokenManager.getToken();
    if (_token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
      setState(() {
        _photoUrl = decodedToken['UserAvatar'];
        _userName = decodedToken['FullName'];
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
        .withAutomaticReconnect([0, 2000, 10000, 30000]) // Configuring automatic reconnect
        .build();

    _connection.onclose((error) async {
      print('Connection closed. Error: $error');
      await reconnect();
    });

    try {
      await _connection.start();
      print('SignalR connection established.');
      _locationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        sendCurrentLocation();
      });
    } catch (e) {
      print('Failed to start SignalR connection: $e');
      await reconnect();
    }
  }

  Future<void> reconnect() async {
    int retryInterval = 1000; // Initial retry interval to 1 second
    while (_connection.state != HubConnectionState.connected) {
      await Future.delayed(Duration(milliseconds: retryInterval));
      try {
        await _connection.start();
        print("Reconnected to SignalR server.");
        return; // Exit the loop if connected
      } catch (e) {
        print("Reconnect failed: $e");
        retryInterval = (retryInterval < 5000) ? retryInterval + 1000 : 5000; // Cap retry interval at 5 seconds
      }
    }
  }

  Future<void> sendCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // Decode token to get main latitude, longitude, and max distance
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
      double mainLat = double.parse(decodedToken['MainLatitude']);
      double mainLon = double.parse(decodedToken['MainLongitude']);
      double maxDistance = double.parse(decodedToken['MaxDistance']);

      // Calculate distance using Haversine formula
      double distance = HaversineCalculator.haversine(position.latitude, mainLat, position.longitude, mainLon);
      print('$maxDistance,mainlong$mainLon,mainlat$mainLat,$position');
      print('$distance');
      // Check if the distance is greater than the maximum allowed distance
      if (distance > maxDistance) {
        // If distance is greater, perform the invoke function
        await _connection.invoke('SendGPSToFamilies', args: [position.latitude, position.longitude]);
        print('Location sent: ${position.latitude}, ${position.longitude}');
      } else {
        print('Distance less than max distance. Location not sent.');
      }
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'LilitaOne',
            fontSize: SizerUtil.deviceType == DeviceType.mobile ? 5.5.w : 23,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A95E9), Color(0xFF38A4C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(10.0.sp),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(66, 55, 134, 190),
                offset: const Offset(0, 10),
                blurRadius: 10.0.sp,
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50.0.sp),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xffD6DCE9),
          child: ListView(
            children: [
              DrawerHeader(
                child: Center(
                  child: Text(
                    'Elder Helper',
                    style: TextStyle(
                      fontSize: SizerUtil.deviceType == DeviceType.mobile ? 8.0.w : 44.0,
                      fontFamily: 'Acme',
                      color: const Color(0xFF0386D0),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.manage_accounts_rounded,
                  color: const Color.fromARGB(255, 84, 134, 235),
                  size: SizerUtil.deviceType == DeviceType.mobile ? 5.0.w : 24.0,
                ),
                title: Text(
                  'Manage Profile',
                  style: TextStyle(
                    fontSize: SizerUtil.deviceType == DeviceType.mobile ? 4.5.w : 20.0,
                    color: const Color(0xFF595858),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PatientProfManage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: const Color.fromARGB(214, 209, 8, 8),
                  size: SizerUtil.deviceType == DeviceType.mobile ? 5.0.w : 24.0,
                ),
                title: Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: SizerUtil.deviceType == DeviceType.mobile ? 4.5.w : 20.0,
                    color: const Color(0xFF595858),
                  ),
                ),
                onTap: () {
                  TokenManager.deleteToken();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPageAll()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffECEFF5),
              Color(0xff3B5998),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 2.0.h), // Responsive padding
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Ensure text starts from the top
                children: [
                  CircleAvatar(
                    radius: 12.w, // Responsive avatar radius
                    backgroundImage: NetworkImage(_photoUrl ?? ''),
                  ),
                  SizedBox(width: 4.0.w), // Responsive spacing between avatar and text
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome $_userName !👋🏻',
                          style: TextStyle(
                            fontSize: 3.w, // Responsive font size
                          ),
                          maxLines: 1, // Ensure the text doesn't exceed one line
                          overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                        ),
                        Text(
                          'To the Electronic mind',
                          style: TextStyle(
                            fontSize: 3.w, // Responsive font size
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'of Alzheimer patient',
                          style: TextStyle(
                            fontSize: 3.w, // Responsive font size
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0.w),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AppointmentScreenPatient()),
                              );
                            },
                            child: Image.asset(
                              'images/appoinmentpat.png'.tr(),
                              width: 30.0.w,
                              height: 30.0.w,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const MedicinesPage()),
                              );
                            },
                            child: Image.asset(
                              'images/Medicines.png'.tr(),
                              width: 30.0.w,
                              height: 30.0.w,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const UnusualFamilyList()),
                              );
                            },
                            child: Image.asset(
                              'images/Places.png'.tr(),
                              width: 30.0.w,
                              height: 30.0.w,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              String? token = await TokenManager.getToken();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChatScreen(token: token!)), // todo: replace authToken with your token
                              );
                            },
                            child: Image.asset(
                              'images/Chatbot.png'.tr(),
                              width: 30.0.w,
                              height: 30.0.w,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Notes_View()),
                              );
                            },
                            child: Image.asset(
                              'images/Notes.png'.tr(),
                              width: 30.0.w,
                              height: 30.0.w,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const SecretFilePage()),
                              );
                            },
                            child: Image.asset(
                              'images/Files.png'.tr(),
                              width: 30.0.w,
                              height: 30.0.w,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const ImageUploadScreen()),
                              );
                            },
                            child: Image.asset(
                              'images/Persons.png'.tr(),
                              width: 30.0.w,
                              height: 30.0.w,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const GalleryScreenPatient()),
                              );
                            },
                            child: Image.asset(
                              'images/Pictures.png'.tr(),
                              width: 30.0.w,
                              height: 30.0.w,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const Home()),
                              );
                            },
                            child: Image.asset(
                              'images/dailytasks.png'.tr(),
                              width: 28.0.w,
                              height: 28.0.w,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LevelSelectionScreen()));
                            },
                            child: Image.asset(
                              'images/Games (1).png'.tr(),
                              width: 27.0.w,
                              height: 27.0.w,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HaversineCalculator {
  static double haversine(double newLat1, double mainLat2, double newLon1, double mainLon2) {
    const double r = 6371e3; // meters
    var dLat = _toRadians(mainLat2 - newLat1);
    var dLon = _toRadians(mainLon2 - newLon1);

    var a = pow(sin(dLat / 2), 2) + cos(_toRadians(newLat1)) * cos(_toRadians(mainLat2)) * pow(sin(dLon / 2), 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    var d = r * c;
    return d; // return distance in meters
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }
}
