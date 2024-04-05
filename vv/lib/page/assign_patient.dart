import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vv/api/login_api.dart';

class assignPatient extends StatefulWidget {
  @override
  _assignPatientState createState() => _assignPatientState();
}

class _assignPatientState extends State<assignPatient> {
  final TextEditingController _patientCodeController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();

  Future<void> _submitPatientRelation() async {
    try {
      final response = await DioService().dio.put(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/AssignPatientToFamily', // Replace with your actual endpoint
        data: {
          "patientCode": _patientCodeController.text,
          "relationility": _relationController.text,
        },
      );
      if (response.statusCode == 200) {
        // Handle response
        print("Data sent successfully");
        Navigator.of(context).pop(); // Close the screen on success
      } else {
        // Handle error
        print("Failed to send data");
      }
    } catch (e) {
      print("Error sending data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300, // Light grey background
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
              width: 300, // Fixed width for the card
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
                    'Add Patient Relation',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Patient Code',
                      border: OutlineInputBorder(),
                    ),
                    controller: _patientCodeController,
                  ),
                  SizedBox(height: 24),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Relation',
                      border: OutlineInputBorder(),
                    ),
                    controller: _relationController,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitPatientRelation,
                    child: Text('Submit'),
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