import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vv/Family/Languagefamily/Languagefamily.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Notes/views/Notes_view/Notes_view.dart';
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
  // ignore: library_private_types_in_public_api
  _mainpatientState createState() => _mainpatientState();
}

// ignore: camel_case_types
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
      // Optionally initiate a manual reconnect here if automatic reconnect is not sufficient
      await reconnect();
    });

    try {
      await _connection.start();
      print('SignalR connection established.');
      // Start sending location every minute after the connection is established
      _locationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        sendCurrentLocation();
      });
    } catch (e) {
      print('Failed to start SignalR connection: $e');
      await reconnect();
    }
  }

  Future<void> reconnect() async {
    int retryInterval = 1000; // Initial retry interval to 5 seconds
    while (_connection.state != HubConnectionState.connected) {
      await Future.delayed(Duration(milliseconds: retryInterval));
      try {
        await _connection.start();
        print("Reconnected to SignalR server.");
        return; // Exit the loop if connected
      } catch (e) {
        print("Reconnect failed: $e");
        retryInterval = (retryInterval < 1000)
            ? retryInterval + 1000
            : 1000; // Increase retry interval, cap at 1 seconds
      }
    }
  }

  Future<void> sendCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await _connection.invoke('SendGPSToFamilies',
          args: [position.latitude, position.longitude]);
      print('Location sent: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel(); // Cancel the timer when the widget is disposed
    _connection.stop(); // Optionally stop the connection
    super.dispose();
  }

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
            Positioned(
              top: 132,
              left: 45,
              child: Container(
                child: Image.asset(
                  'images/appoinmentpat.png',
                  width: 110,
                  height: 110,
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