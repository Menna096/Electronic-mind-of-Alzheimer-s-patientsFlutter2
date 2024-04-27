import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vv/Family/appoint_details.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/task_widgets/dayselect.dart';
import 'package:vv/widgets/task_widgets/yearmonth.dart';
import '../../models/appoint.dart';
import 'addApoint.dart';

class AppointListScreen extends StatefulWidget {
  @override
  _AppointListScreenState createState() => _AppointListScreenState();
}

class _AppointListScreenState extends State<AppointListScreen> {
  List<Appointment> Appoints = [];
  Appointment? selectedAppoint;
  late HubConnection _connection;
  String _currentLocation = "Waiting for location...";
  bool _locationReceived = false;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin(); //
  Color pickedColor = const Color(0xFF0386D0);
  void updateAppoint(Appointment oldAppoint, Appointment newAppoint) {
    setState(() {
      final index = Appoints.indexOf(oldAppoint);
      Appoints[index] = newAppoint;
    });
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

  @override
  void dispose() {
    _connection.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: AlignmentDirectional.bottomCenter,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xffFFFFFF),
            Color(0xff3B5998),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              elevation: 2, // Adjust the elevation as needed
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(39.0),
                bottomRight: const Radius.circular(39.0),
              ),
              color: const Color.fromRGBO(255, 255, 255, 0.708),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(39.0),
                  bottomRight: Radius.circular(39.0),
                ),
                child: Container(
                  decoration: const BoxDecoration(),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      const Center(
                        child: Text(
                          'Appointments',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                      const backbutton(),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 40,
                          ),
                          const CurrentMonthYearWidget(),
                          const SizedBox(
                            width: 40,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AddAppointmentScreen(
                                              onAppointAdded: addAppoint)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // Set circular border radius
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 30),
                                // Increase vertical padding
                                elevation: 4,
                                backgroundColor:
                                    pickedColor, // Add some elevation
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    'Add ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text('Appointment',
                                      style: TextStyle(color: Colors.white))
                                ],
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: DaySelector(),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                'Appointments',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: Appoints.length,
                itemBuilder: (context, index) {
                  return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(168, 255, 255, 255)
                            .withOpacity(
                                0.2), // Set white color with 50% opacity
                        borderRadius:
                            BorderRadius.circular(20.0), // Set circular edges
                      ),
                      child: ListTile(
                        //
                        leading: const Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.white,
                        ),
                        title: Text(Appoints[index].name),
                        subtitle: Text(
                          '${DateTime.now().day}. ${DateFormat('MMM').format(DateTime.now())}. ${DateTime.now().year}',
                        ),
                        trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.delete),
                          color: const Color.fromARGB(255, 63, 63, 63),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppointDetailsScreen(
                                appoint: Appoints[index],
                                onAppointUpdated: (editedAppoint) {
                                  updateAppoint(Appoints[index], editedAppoint);
                                },
                              ),
                            ),
                          );
                        },
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addAppoint(Appointment appoint) {
    setState(() {
      Appoints.add(appoint);
    });
  }
}