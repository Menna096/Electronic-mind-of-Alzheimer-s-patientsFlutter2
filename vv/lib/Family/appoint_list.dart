import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vv/Family/FinalapponitDetail.dart';
import 'package:vv/api/login_api.dart';  // Ensure this import is correct for your project
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
  List<dynamic> appointments = [];
  late HubConnection _connection;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  Color pickedColor = const Color(0xFF0386D0);

  @override
  void initState() {
    super.initState();
    initNotifications();
    initializeSignalR();
    fetchAppointments();
  }

  Future<void> initializeSignalR() async {
    _connection = HubConnectionBuilder()
        .withUrl(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/hubs/appointment',
          HttpConnectionOptions(
            accessTokenFactory: () async => await TokenManager.getToken(),
            logging: (level, message) => print(message),
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection.on('NewAppointmentAdded', (arguments) {
      print('New appointment added: $arguments');
      fetchAppointments();  // Re-fetch the appointments to update the UI
    });

    try {
      await _connection.start();
      print('SignalR connection established.');
    } catch (e) {
      print('Failed to start SignalR connection: $e');
    }
  }

  Future<void> fetchAppointments() async {
    try {
      final response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/GetPatientAppointments');
      setState(() {
        appointments = response.data;
      });
    } catch (e) {
      print('Error fetching appointments: $e');
    }
  }

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments List'),
     
      ),
      body: Container(
        alignment: AlignmentDirectional.bottomCenter,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffFFFFFF), Color(0xff3B5998)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurrentMonthYearWidget(),
            DaySelector(),
            Expanded(
              child: ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return ListTile(
                    leading: Icon(Icons.calendar_today_rounded),
                    title: Text(appointment['title']),
                    subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(appointment['date']))),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AppointmentDetailsScreen(appointment: appointment)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAppointmentScreen()),
          );
        },
        tooltip: 'Add Appointment',
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _connection.stop();
    super.dispose();
  }
}
