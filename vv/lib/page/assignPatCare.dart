import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/api/login_api.dart'; // Ensure this import is correct

class AssignPatientPage extends StatefulWidget {
  @override
  _AssignPatientPageState createState() => _AssignPatientPageState();
}

class _AssignPatientPageState extends State<AssignPatientPage> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> assignPatientToCaregiver(String caregiverCode) async {
    String url =
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/AssignPatientToCaregiver/$caregiverCode';

    try {
      Response response = await DioService().dio.put(url);

      if (response.statusCode == 200) {
        // Success response handling
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Patient assigned successfully'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      } else {
        // Error handling for non-successful response
        print("Failed to assign patient. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // Error handling for request failure
      print("Error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close_rounded),
                          tooltip: 'Exit',
                          onPressed: () {
                            // Navigate to the target screen when the button is pressed
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainPageFamily()),
                            );
                          },
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          'Assign Patient \n To Caregiver',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Enter Caregiver Code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a caregiver code';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          assignPatientToCaregiver(_controller.text.trim());
                        }
                      },
                      child: Text(
                        'Assign Patient',
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
      ),
    );
  }
}
