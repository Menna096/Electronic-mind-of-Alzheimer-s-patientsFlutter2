import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/page/assign_patient.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:geolocator/geolocator.dart';

class AddPatientScreen extends StatefulWidget {
  @override
  _AddPatientScreenState createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  String patientCode = 'Loading...';
  late HubConnection _connection;
  Timer? _locationTimer; // Initialize Dio

  @override
  void initState() {
    super.initState();
    initializeSignalR(); 
    _fetchPatientCode();
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

  Future<void> _fetchPatientCode() async {
    try {
      final response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/GetPatientCode');
      if (response.statusCode == 200) {
        var responseData = response.data;
        String code = responseData['code'];
        setState(() {
          patientCode = code;
        });
      } else {
        _navigateToAssignPatientScreen(); // No patient code found, navigate directly
      }
    } catch (e) {
      _navigateToAssignPatientScreen(); // Error occurred, navigate directly
      print(e);
    }
  }

  void _navigateToAssignPatientScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  assignPatient()), // Ensure this is the correct class name for your Assign Patient Screen
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // If patientCode is still 'Loading...', we show a loading indicator instead of immediately building the UI
    if (patientCode == 'Loading...') {
      return Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Once patientCode is fetched, or if an error occurs (and is handled), the below UI is built
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Center(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.blue.shade900],
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: 300,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Add Patient',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Patient ID',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Rounded corners
                        borderSide: BorderSide(
                          color: Colors.black, // Default border color
                          width: 1.0, // Default border width
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 10.0),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: patientCode))
                              .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Patient ID copied to clipboard!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          });
                        },
                      ),
                    ),
                    readOnly: true,
                    controller: TextEditingController(text: patientCode),
                    style: TextStyle(fontSize: 20),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Please send it to anyone responsible for the patient',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MainPageFamily()), // Ensure this is the correct class name for your Main Page Family
                      );
                    },
                    child: Text(
                      'Done',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      fixedSize: Size(150, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
