import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:vv/Family/enterimage.dart';

import 'package:vv/api/login_api.dart';
import 'package:vv/faceid.dart';
import 'package:vv/page/addpat.dart';

class assignPatient extends StatefulWidget {
  const assignPatient({super.key});

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
          SnackBar(
            content: Text("Patient assigned successfully".tr()),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Handle error
        print("Failed to send data");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Patient assign failed. Please try again".tr()),
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
            _createRoute(const UploadImagesPage()),
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color.fromARGB(255, 156, 195, 255)
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
                  boxShadow: const [
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
                    Row(
                      children: [
                        Text(
                          'Assign Patient'.tr(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Patient Code'.tr(),
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
                        'Mother'.tr(),
                        'Father'.tr(),
                        'Brother'.tr(),
                        'Sister'.tr(),
                        'Grandmother'.tr(),
                        'Grandfather'.tr(),
                        'Grandson'.tr(),
                        'Granddaughter'.tr(),
                        'Husband'.tr(),
                        'Wife'.tr(),
                        'Son'.tr(),
                        'Daughter'.tr(),
                        'Aunt'.tr(),
                        'Uncle'.tr(),
                        'Niece'.tr(),
                        'Nephew'.tr(),
                        'Cousin'.tr(),
                        'Mother-in-law'.tr(),
                        'Father-in-law'.tr(),
                        'Brother-in-law'.tr(),
                        'Sister-in-law'.tr(),
                        'Stepfather'.tr(),
                        'Stepmother'.tr(),
                        'Stepbrother'.tr(),
                        'Stepsister'.tr(),
                        'Half-brother'.tr(),
                        'Half-sister'.tr(),
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Relationility'.tr(),
                        labelStyle:
                            TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Select Relationility'.tr(),
                        hintStyle: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.w300),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Description For Patient'.tr(),
                        border: OutlineInputBorder(),
                      ),
                      controller: _descriptionContrller,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _handleSubmitAndCheckTrain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        fixedSize: const Size(150, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Text(
                        'Submit'.tr(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const Addpat(), // Ensure this is the correct class name for your Assign Patient Screen
                          ),
                        );
                      },
                      child: Text('Create New Patient Account'.tr()),
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
