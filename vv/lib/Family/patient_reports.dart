import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/utils/storage_manage.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:vv/widgets/background.dart';

class ReportListScreenFamily extends StatefulWidget {
  @override
  _ReportListScreenFamilyState createState() => _ReportListScreenFamilyState();
}

class _ReportListScreenFamilyState extends State<ReportListScreenFamily> {
  bool isLoading = true;
  List<dynamic> reports = [];
  late HubConnection _connection;
  String _currentLocation = "Waiting for location...";
  bool _locationReceived = false;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    _fetchReports();
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

  Future<void> _fetchReports() async {
    try {
      // Fetch patient ID from secure storage
      final response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/GetPatientReports');
      setState(() {
        reports = response.data; // assuming response.data is List<dynamic>
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        print('Failed to fetch reports: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Reports'),
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MainPageFamily()), // Ensure this is the correct class name for your Assign Patient Screen
              );
            },
            icon: Icon(Icons.arrow_back)),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Background(
              SingleChildScrollView: null,
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(report['reportContent'],
                          style: TextStyle(fontSize: 18)),
                      subtitle: Text(
                          'From: ${report['fromDate']} To: ${report['toDate']}'),
                      leading: Icon(Icons.edit,
                          color: Theme.of(context).primaryColor),
                    ),
                  );
                },
              ),
            ),
    );
  }
}