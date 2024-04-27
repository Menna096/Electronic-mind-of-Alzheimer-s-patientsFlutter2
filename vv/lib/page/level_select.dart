import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/map_location_picker.dart';
import 'package:vv/page/game_history.dart';
import 'package:vv/page/memory_game.dart';
import 'package:vv/utils/token_manage.dart';

import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/background.dart';

class LevelSelectionScreen extends StatefulWidget {
  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  int? recommendedLevel;
  late HubConnection _connection;
  Timer? _locationTimer;
  @override
  void initState() {
    super.initState();
    fetchRecommendedLevel();
    initializeSignalR();
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

  Future<void> fetchRecommendedLevel() async {
    try {
      var response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetAllGameScores');
      if (response.statusCode == 200) {
        setState(() {
          recommendedLevel = response.data['recomendationDifficulty'];
        });
      }
    } catch (e) {
      print('Failed to fetch recommended level: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: buildAppBar('Memory Card Game'),
      body: Background(
        SingleChildScrollView: null,
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 25,
              ),
              Text(
                'Memory Card Game',
                style: TextStyle(fontSize: 35),
              ),
              Row(
                children: [
                  backbutton(),
                  Spacer(
                    flex: 1,
                  ),
                  Column(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HistoryScreen()),
                            );
                          },
                          icon: Icon(
                            Icons.history,
                            size: 40,
                            color: Colors.grey,
                          )),
                    ],
                  )
                ],
              ),
              Spacer(flex: 1),
              Text(
                'Welcome To Memory Card Game',
                style: TextStyle(fontSize: 22),
              ),
              Text(
                'Please select a level',
                style: TextStyle(fontSize: 22),
              ),
              Spacer(flex: 3),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: recommendedLevel != null
                        ? () => navigateToMemoryCardGame(
                            context, recommendedLevel! + 1)
                        : null,
                    child: Text(recommendedLevel == 0
                            ? 'Recommended Level: Easy'
                            : recommendedLevel == 1
                                ? 'Recommended Level: Medium'
                                : recommendedLevel == 2
                                    ? 'Recommended Level: Hard'
                                    : 'Recommended Level: $recommendedLevel' // Fallback for other values
                        ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF0386D0),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  buildLevelButton(context, "Easy (6 pairs)", 1),
                  SizedBox(height: 10),
                  buildLevelButton(context, "Medium (12 pairs)", 2),
                  SizedBox(height: 10),
                  buildLevelButton(context, "Hard (18 pairs)", 3),
                  SizedBox(height: 20),
                ],
              ),
              Spacer(flex: 5)
            ],
          ),
        ),
      ),
    );
  }
}

ElevatedButton buildLevelButton(BuildContext context, String text, int level) {
  return ElevatedButton(
    onPressed: () => navigateToMemoryCardGame(context, level),
    child: Text(text),
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Color(0xFF0386D0),
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(27.0),
      ),
    ),
  );
}

void navigateToMemoryCardGame(BuildContext context, int level) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MemoryCardGame(level: level),
    ),
  );
}