import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:sizer/sizer.dart';
import 'package:vv/Family/AddPersonWithoutAccount.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Family/appoint_list.dart';
import 'package:vv/Family/patientLocToday.dart';
import 'package:vv/Family/patient_reports.dart';
import 'package:vv/Family/update.dart';
import 'package:vv/page/assignPatCare.dart';
import 'package:vv/page/gallery_screen.dart';
import 'package:vv/page/paitent_Id.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:vv/widgets/background.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MainPageFamily extends StatefulWidget {
  const MainPageFamily({super.key});

  @override
  _MainPageFamilyState createState() => _MainPageFamilyState();
}

class _MainPageFamilyState extends State<MainPageFamily> {
  late HubConnection _connection;
  final String _currentLocation = "Waiting for location...".tr();
  final bool _locationReceived = false;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String? _token;
  String? _photoUrl;
  String? _userName;
  @override
  void initState() {
    super.initState();
    // initializeSignalR();
    // initNotifications();
    _getDataFromToken();
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

  // Future<void> initNotifications() async {
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //       AndroidInitializationSettings('@mipmap/ic_launcher');
  //   final InitializationSettings initializationSettings =
  //       InitializationSettings(
  //     android: initializationSettingsAndroid,
  //   );
  //   await _notificationsPlugin.initialize(
  //     initializationSettings,
  //     onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
  //   );
  // }

  // void onDidReceiveNotificationResponse(
  //     NotificationResponse notificationResponse) {
  //   if (notificationResponse.payload != null) {
  //     var data = notificationResponse.payload!.split(',');
  //     double latitude = double.parse(data[0]);
  //     double longitude = double.parse(data[1]);
  //     _launchGoogleMaps(latitude, longitude);
  //   }
  // }

  // Future<void> initializeSignalR() async {
  //   _connection = HubConnectionBuilder()
  //       .withUrl(
  //         'https://electronicmindofalzheimerpatients.azurewebsites.net/hubs/GPS',
  //         HttpConnectionOptions(
  //           accessTokenFactory: () async => await TokenManager.getToken(),
  //           logging: (level, message) => print(message),
  //         ),
  //       )
  //       .withAutomaticReconnect()
  //       .build();

  //   _connection.on('ReceiveGPSToFamilies', (arguments) {
  //     if (arguments != null && arguments.length >= 2) {
  //       double latitude = arguments[0];
  //       double longitude = arguments[1];
  //       setState(() {
  //          _currentLocation = 'current_location'.tr(args: [latitude.toString(), longitude.toString()]);
  //         _locationReceived = true;
  //       });
  //       _showNotification(latitude, longitude);
  //       print('Patient is out of the zone!!');
  //     }
  //   });

  //   try {
  //     await _connection.start();
  //     print('SignalR connection established.');
  //   } catch (e) {
  //     print('Failed to start SignalR connection: $e');
  //     setState(() {
  //       _currentLocation = 'Error starting connection'.tr();
  //     });
  //   }
  // }

  // Future<void> _showNotification(double latitude, double longitude) async {
  //   AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'your channel id',
  //     'your channel name',
  //     channelDescription: 'your channel description',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     ticker: 'ticker',
  //     sound: RawResourceAndroidNotificationSound('sound.m4a'.split('.').first),
  //   );
  //   NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);
  //   await _notificationsPlugin.show(
  //     0,
  //     'New Location Received'.tr(),
  //     'Patient is out of the zone'.tr(),
  //     platformChannelSpecifics,
  //     payload: '$latitude,$longitude',
  //   );
  // }

  // Future<void> _launchGoogleMaps(double latitude, double longitude) async {
  //   final url = 'geo:0,0?q=$latitude,$longitude';
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings'.tr(),
          style: TextStyle(
            fontFamily: 'LilitaOne',
            fontSize: 6.w, // Responsive font size
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
              bottom: Radius.circular(2.h), // Responsive border radius
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(66, 55, 134, 190),
                offset: Offset(0, 1.h), // Responsive offset
                blurRadius: 1.5.h, // Responsive blur radius
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10.w), // Responsive border radius
          ),
        ),
      ),
      drawer: buildDrawer(context),
      resizeToAvoidBottomInset: false,
      body: Background(
        SingleChildScrollView: null,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0.w), // Responsive padding
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Adjust alignment as needed
                children: [
                  CircleAvatar(
                    radius: 12.0.w, // Responsive avatar radius
                    backgroundImage: NetworkImage(_photoUrl ?? ''),
                  ),
                  SizedBox(width: 2.0.w), // Responsive spacing
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2.0.w),
                        Text(
                          'Welcome {name}!'
                              .tr(namedArgs: {'name': _userName ?? ''}),
                          style: TextStyle(
                            fontSize: 4.5.w, // Responsive font size
                          ),
                          maxLines:
                              1, // Limit text to one line to prevent overflow
                          overflow: TextOverflow
                              .ellipsis, // Handle overflow with ellipsis
                        ),
                        SizedBox(height: 1.0.h), // Responsive spacing
                        Text(
                          'To The Electronic Mind Of Alzheimer Patient!👋🏻'
                              .tr(),
                          style: TextStyle(
                            fontSize: 4.5.w, // Responsive font size
                          ),
                          maxLines: 2,
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
                padding: EdgeInsets.symmetric(
                    horizontal: 4.0.w), // Responsive padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const GalleryScreen()),
                            );
                          },
                          child: Image.asset(
                            'images/Picfamm.png'.tr(),
                            width: 40.0.w, // Responsive image width
                            height: 40.0.w, // Responsive image height
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AddPatientScreen()),
                            );
                          },
                          child: Image.asset(
                            'images/Pattcode.png'.tr(),
                            width: 40.0.w, // Responsive image width
                            height: 40.0.w, // Responsive image height
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
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AssignPatientPage()),
                            );
                          },
                          child: Image.asset(
                            'images/assignCare.png'.tr(),
                            width: 40.0.w, // Responsive image width
                            height: 40.0.w, // Responsive image height
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const PatientLocationsScreen()),
                            );
                          },
                          child: Image.asset(
                            'images/PlaceFamm.png'.tr(),
                            width: 40.0.w, // Responsive image width
                            height: 40.0.w, // Responsive image height
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
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ReportListScreenFamily()),
                            );
                          },
                          child: Image.asset(
                            'images/reppfamm.png'.tr(),
                            width: 40.0.w, // Responsive image width
                            height: 40.0.w, // Responsive image height
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AppointListScreen()),
                            );
                          },
                          child: Image.asset(
                            'images/Appointmmfam.png'.tr(),
                            width: 40.0.w, // Responsive image width
                            height: 40.0.w, // Responsive image height
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xffD6DCE9),
        child: ListView(
          children: [
            DrawerHeader(
              child: Center(
                child: Text(
                  'Elder Helper'.tr(),
                  style: TextStyle(
                    fontSize: 8.w, // Responsive font size
                    fontFamily: 'Acme',
                    color: const Color(0xFF0386D0),
                  ),
                ),
              ),
            ),
            buildDrawerItem(
              Icons.person_add_alt_1_sharp,
              'Add Patient'.tr(),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const update()));
              },
            ),
            buildDrawerItem(
              Icons.person_add_alt_1_sharp,
              'Add Person Without Account'.tr(),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddPerson()));
              },
            ),
            buildDrawerlogout(
              Icons.logout_outlined,
              'Log Out'.tr(),
              onTap: () {
                TokenManager.deleteToken();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LoginPageAll()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDrawerItem(IconData icon, String title, {Function? onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF0386D0),
        size: 8.w, // Responsive icon size
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 3.5.w, // Responsive font size
          color: const Color(0xFF595858),
        ),
      ),
      onTap: onTap as void Function()?,
    );
  }

  Widget buildDrawerlogout(IconData icon, String title, {Function? onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color.fromARGB(255, 174, 5, 5),
        size: 8.w, // Responsive icon size
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 3.5.w, // Responsive font size
          color: const Color(0xFF595858),
        ),
      ),
      onTap: onTap as void Function()?,
    );
  }
}
