import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // A collection of loading indicators
import 'package:dio/dio.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/map_location_picker.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:vv/widgets/background.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> gameHistories = [];
  bool isLoading = true;
  late HubConnection _connection;
  Timer? _locationTimer;
  @override
  void initState() {
    super.initState();
    _fetchGameData();
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

  Future<void> _fetchGameData() async {
    var dio = Dio();
    try {
      final response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetAllGameScores');
      List<dynamic> data = response.data['gameScore'];
      setState(() {
        gameHistories = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        print('Failed to load data: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game History"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Background(
        SingleChildScrollView: null,
        child: Center(
          child: isLoading
              ? const SpinKitFadingCircle(
                  color: Colors.blueAccent,
                  size: 50.0) // Improved loading indicator
              : gameHistories.isEmpty
                  ? const Text(
                      "No history available.",
                      style: TextStyle(fontSize: 18.0, color: Colors.black54),
                    )
                  : ListView.builder(
                      itemCount: gameHistories.length,
                      itemBuilder: (context, index) {
                        final item = gameHistories[index];
                        return Card(
                          // Encapsulate each list item in a Card widget for better UI
                          elevation: 2.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 10),
                          child: ListTile(
                            leading: const Icon(Icons.gamepad,
                                color: Colors.blueAccent),
                            title: const Text('Game Score',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Difficulty: ${item['difficultyGame']}, Score: ${item['patientScore']}'),
                            // trailing: Icon(Icons.arrow_forward_ios),
                            // onTap: () {
                            //   // Implement tap action if necessary
                            // },
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}