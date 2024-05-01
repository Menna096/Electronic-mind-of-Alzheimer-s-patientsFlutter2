import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vv/Family/Languagefamily/Languagefamily.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Notes/views/Notes_view/Notes_view.dart';
import 'package:vv/Patient/appoint.dart';
import 'package:vv/Patient/mainpagepatient/all_families.dart';
import 'package:vv/Patient/mainpagepatient/patient_media.dart';
import 'package:vv/Patient/mainpagepatient/patient_prof.dart';
import 'package:vv/Patient/mainpagepatient/vediooooo/show_sec.dart';
import 'package:vv/daily_task/pages/home/home_page.dart';
import 'package:vv/page/level_select.dart';
import 'package:vv/utils/token_manage.dart';

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

  @override
  void initState() {
    super.initState();
    _getDataFromToken();
    initializeSignalR();
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
        .withAutomaticReconnect(
            [0, 2000, 10000, 30000]) // Configuring automatic reconnect
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
        retryInterval = (retryInterval < 5000)
            ? retryInterval + 1000
            : 5000; // Cap retry interval at 5 seconds
      }
    }
  }

  Future<void> sendCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Decode token to get main latitude, longitude, and max distance
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
      double mainLat = double.parse(decodedToken['MainLatitude']);
      double mainLon = double.parse(decodedToken['MainLongitude']);
      double maxDistance = double.parse(decodedToken['MaxDistance']);

      // Calculate distance using Haversine formula
      double distance = HaversineCalculator.haversine(
          position.latitude, mainLat, position.longitude, mainLon);
      print('$maxDistance,mainlong$mainLon,mainlat$mainLat,$position');
      print('$distance');
      // Check if the distance is greater than the maximum allowed distance
      if (distance > maxDistance) {
        // If distance is greater, perform the invoke function
        await _connection.invoke('SendGPSToFamilies',
            args: [position.latitude, position.longitude]);
        print('Location sent: ${position.latitude}, ${position.longitude}');
      } else {
        print('Distance less than max distance. Location not sent.');
      }
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  // @override
  // void dispose() {
  //   // Dispose any resources
  //   _locationTimer?.cancel();
  //   _connection.stop();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 84, 134, 235),
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xffD6DCE9),
          child: ListView(
            children: [
              const DrawerHeader(
                child: Center(
                  child: Text(
                    'Elder Helper',
                    style: TextStyle(
                      fontSize: 44,
                      fontFamily: 'Acme',
                      color: Color(0xFF0386D0),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.manage_accounts_rounded),
                title: const Text(
                  'Manage Profile',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF595858),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PatientProfManage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text(
                  'Language',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF595858),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Language()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_outlined),
                title: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF595858),
                  ),
                ),
                onTap: () {
                  TokenManager.deleteToken();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPageAll()),
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
        child: Stack(
          children: [
            Positioned(
              bottom: 570,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(50, 33, 149, 243),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50.0),
                      bottomRight: Radius.circular(50.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 45.0,
                        backgroundImage: NetworkImage(_photoUrl ?? ''),
                      ),
                      const SizedBox(width: 16.0),
                      Column(
                        children: [
                          Text(
                            'Welcome $_userName !',
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const Text(
                            'To the Electronic mind',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const Text(
                            'of Alzheimer patient',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 332,
              left: 45,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Notes_View()),
                  );
                },
                child: Container(
                  child: Image.asset(
                    'images/Notes.png',
                    width: 110,
                    height: 110,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 232,
              left: 45,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UnusualFamilyList()),
                  );
                },
                child: Container(
                  child: Image.asset(
                    'images/Places.png',
                    width: 110,
                    height: 110,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 432,
              left: 45,
              child: Container(
                child: Image.asset(
                  'images/Persons.png',
                  width: 110,
                  height: 110,
                ),
              ),
            ),
            Positioned(
              top: 530,
              left: 43,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                  );
                },
                child: Container(
                  child: Image.asset(
                    'images/dailytasks.png',
                    width: 115,
                    height: 115,
                  ),
                ),
              ),
            ),
            //
            Positioned(
              top: 132,
              left: 45,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignalRWidget()),
                  );
                },
                child: Container(
                  child: Image.asset(
                    'images/appoinmentpat.png',
                    width: 110,
                    height: 110,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 132,
              left: 230,
              child: Container(
                child: Image.asset(
                  'images/Medicines.png',
                  width: 110,
                  height: 110,
                ),
              ),
            ),
            Positioned(
              top: 232,
              left: 230,
              child: Container(
                child: Image.asset(
                  'images/Chatbot.png',
                  width: 110,
                  height: 110,
                ),
              ),
            ),
            Positioned(
              top: 332,
              left: 230,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SecretFilePage()),
                  );
                },
                child: Container(
                  child: Image.asset(
                    'images/Files.png',
                    width: 110,
                    height: 110,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 432,
              left: 230,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GalleryScreenPatient()),
                  );
                },
                child: Container(
                  child: Image.asset(
                    'images/Pictures.png',
                    width: 110,
                    height: 110,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 532,
              left: 233,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => LevelSelectionScreen()));
                },
                child: Container(
                  child: Image.asset(
                    'images/Games (1).png',
                    width: 110,
                    height: 110,
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
  static double haversine(
      double newLat1, double mainLat2, double newLon1, double mainLon2) {
    const double r = 6371e3; // meters
    var dLat = _toRadians(mainLat2 - newLat1);
    var dLon = _toRadians(mainLon2 - newLon1);

    var a = pow(sin(dLat / 2), 2) +
        cos(_toRadians(newLat1)) *
            cos(_toRadians(mainLat2)) *
            pow(sin(dLon / 2), 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    var d = r * c;
    return d; // return distance in meters
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }
}
