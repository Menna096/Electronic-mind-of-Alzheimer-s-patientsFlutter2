import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vv/Patient/gpsssss/pages/google_map_page.dart';
import 'package:vv/api/login_api.dart'; // Ensure this is correctly implemented
import 'package:vv/map_location_picker.dart';
import 'package:vv/models/family_data.dart';
import 'package:vv/utils/storage_manage.dart';
import 'package:vv/utils/token_manage.dart'; // Ensure this is correctly implemented

class UnusualFamilyList extends StatefulWidget {
  @override
  _UnusualFamilyListState createState() => _UnusualFamilyListState();
}

class _UnusualFamilyListState extends State<UnusualFamilyList>
    with TickerProviderStateMixin {
  late Future<List<FamilyMember>> _familyMembers;
  late AnimationController _controller;
  final SecureStorageManager storageManager = SecureStorageManager();
  late HubConnection _connection;
  Timer? _locationTimer;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _familyMembers = _fetchFamilyMembers();
    _controller.forward();
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

  Future<List<FamilyMember>> _fetchFamilyMembers() async {
    try {
      final response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetPatientRelatedMembers');
      return (response.data as List)
          .map((x) => FamilyMember.fromJson(x))
          .toList();
    } catch (e) {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Family Members"),
        actions: <Widget>[
          IconButton(
            icon: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _controller,
            ),
            onPressed: () {
              if (_controller.isCompleted) {
                _controller.reverse();
              } else {
                _controller.forward();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<FamilyMember>>(
        future: _familyMembers,
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var member = snapshot.data![index];
              return Dismissible(
                key: Key(member.familyId), // Use familyId for uniqueness
                onDismissed: (direction) async {
                  // Store familyId when the item is dismissed
                },
                child: ListTile(
                  title: Text(
                      '${member.familyName} '), // Displaying familyId with familyName
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.relationility),
                      if (member.familyDescriptionForPatient != null)
                        Text(member.familyDescriptionForPatient!),
                    ],
                  ),

                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(member.hisImageUrl),
                  ),
                  trailing: IconButton(
                    onPressed: () async {
                      await storageManager.savefamilyId(member.familyId);
                      final familyLocationResponse = await DioService().dio.get(
                          'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetFamilyLocation/${member.familyId}');
                      final familyLocationData = familyLocationResponse.data;
                      final latitude = familyLocationData['latitude'];
                      final longitude = familyLocationData['longitude'];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NavigationScreen(latitude, longitude),
                        ),
                      );
                    },
                    icon: Icon(Icons.location_on),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
