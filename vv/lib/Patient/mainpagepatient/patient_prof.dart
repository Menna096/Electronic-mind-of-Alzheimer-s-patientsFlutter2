import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/widgets/background.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:geolocator/geolocator.dart';

class PatientProfManage extends StatefulWidget {
  @override
  _PatientProfManageState createState() => _PatientProfManageState();
}

class _PatientProfManageState extends State<PatientProfManage> {
   late HubConnection _connection;
  Timer? _locationTimer; // Initialize Dio
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
      initializeSignalR();
    _fetchUserData();
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

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
        });
      }
    });
  }

  Future<void> _fetchUserData() async {
    try {
      var response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetPatientProfile');
      if (response.statusCode == 200) {
        setState(() {
          _fullNameController.text = response.data['fullName'];
          _phoneController.text = response.data['phoneNumber'];
          _ageController.text = response.data['age'].toString();
          _selectedDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
              .parse(response.data['diagnosisDate']);
          messageController.text = response.data['message'];
          _idController.text = response.data['patientId'];
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> updateUserProfile() async {
    String apiUrl =
        'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/UpdatePatientProfile';
    Map<String, dynamic> requestBody = {
      'phoneNumber': _phoneController.text,
      'age': int.parse(_ageController.text),
      'patientId': _idController.text,
      'fullName': _fullNameController.text,
      'diagnosisDate': _selectedDate != null
          ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(_selectedDate!)
          : null,
      'message': messageController.text,
    };

    try {
      Response response = await DioService().dio.put(
        apiUrl,
        data: requestBody,
        options: Options(
          contentType: 'application/json; charset=UTF-8',
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Failed to update profile. Status code: ${response.statusCode}')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Profile'),
        centerTitle: true,
      ),
      body: Background(
        SingleChildScrollView: null,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                _buildTextField(
                  labelText: 'Message',
                  controller: messageController,
                  maxLines: 3,
                  readOnly: true,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  labelText: 'Your ID',
                  controller: _idController,
                  readOnly: true,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  labelText: 'Full Name',
                  controller: _fullNameController,
                  readOnly: true,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  labelText: 'Phone Number',
                  controller: _phoneController,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  labelText: 'Age',
                  controller: _ageController,
                ),
                SizedBox(height: 20),
                ListTile(
                  title: Text(
                    'Diagnosis Date: ${_selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : "Not set"}',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: null, // Disable onTap
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: updateUserProfile,
                  child: Text('Update Profile'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        hintText: 'Enter $labelText',
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
      ),
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
    );
  }
}
