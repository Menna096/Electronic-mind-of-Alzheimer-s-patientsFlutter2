import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vv/Family/enterimage.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';

import 'package:vv/api/login_api.dart';
import 'package:vv/faceid.dart';
import 'package:vv/page/addpat.dart';
import 'package:vv/widgets/backbutton.dart';

class assignPatient extends StatefulWidget {
  @override
  _assignPatientState createState() => _assignPatientState();
}

class _assignPatientState extends State<assignPatient> {
  final TextEditingController _patientCodeController = TextEditingController();
  final TextEditingController _descriptionContrller = TextEditingController();
  String relationility = ''; // Initialize an empty string for relation

  Future<void> _submitPatientRelation() async {
    try {
      final response = await DioService().dio.put(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/AssignPatientToFamily', // Replace with your actual endpoint
        data: {
          "patientCode": _patientCodeController.text,
          "relationility": relationility,
          "descriptionForPatient": _descriptionContrller.text,
        },
      );
      if (response.statusCode == 200) {
        // Handle response
        print("Data sent successfully");

        // Show SnackBar on the previous screen (since the current one is popped)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Patient assigned successfully"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Handle error
        print("Failed to send data");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Patient assign failed. Please try again"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error sending data: $e");
    }
  }

  Future<void> checkTrain() async {
    try {
      Response response = await DioService().dio.get(
            'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/FamilyNeedATrainingImages',
          );

      if (response.statusCode == 200) {
        bool needTraining = response.data['needATraining'];

        if (needTraining == true) {
          Navigator.push(
            context,
            _createRoute(UploadImagesPage()),
          );
          print('need to train');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _handleSubmitAndCheckTrain() async {
    await _submitPatientRelation();
    await checkTrain();
  }

  PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: Center(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color.fromARGB(255, 156, 195, 255)
                ],
              ),
            ),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 300, // Fixed width for the card
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: [
                        const Text(
                          'Assign Patient',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Patient Code',
                        border: OutlineInputBorder(),
                      ),
                      controller: _patientCodeController,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: relationility.isNotEmpty ? relationility : null,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            relationility = newValue;
                          });
                        }
                      },
                      items: <String>[
                        'Mother',
                        'Father',
                        'Brother',
                        'Sister',
                        'Grandmother',
                        'Grandfather',
                        'Grandson',
                        'Granddaughter',
                        'Husband',
                        'Wife',
                        'Son',
                        'Daughter',
                        'Aunt',
                        'Uncle',
                        'Niece',
                        'Nephew',
                        'Cousin',
                        'Mother-in-law',
                        'Father-in-law',
                        'Brother-in-law',
                        'Sister-in-law',
                        'Stepfather',
                        'Stepmother',
                        'Stepbrother',
                        'Stepsister',
                        'Half-brother',
                        'Half-sister'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Relationility',
                        labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0)),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Select Relationility',
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.w300),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Description For Patient',
                        border: OutlineInputBorder(),
                      ),
                      controller: _descriptionContrller,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _handleSubmitAndCheckTrain,
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        fixedSize: const Size(150, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Addpat(), // Ensure this is the correct class name for your Assign Patient Screen
                          ),
                        );
                      },
                      child: const Text('create new patient account'),
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
