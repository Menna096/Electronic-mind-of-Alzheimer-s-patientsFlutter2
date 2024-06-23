import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart'; // Import mainpagecaregiver.dart
import 'package:vv/api/login_api.dart';
import 'package:vv/utils/storage_manage.dart';
import 'package:vv/widgets/background.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _reportContentController =
      TextEditingController();

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color.fromARGB(255, 84, 134, 235), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Color.fromARGB(255, 84, 134, 235), // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 84, 134, 235), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Use DateFormat with 'en' locale explicitly
        controller.text = DateFormat('yyyy-MM-dd', 'en').format(picked);
        if (controller == _fromDateController) {
          print('Start date: ${controller.text}');
        }
      });
    }
  }

  Widget _buildDateButton(String label, TextEditingController controller) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: () => _selectDate(context, controller),
          child: Text(
            controller.text.isEmpty ? label.tr() : controller.text,
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 77, 125, 221),
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    String? patientId = await SecureStorageManager().getPatientId();
    var data = jsonEncode({
      "fromDate": _fromDateController.text,
      "toDate": _toDateController.text,
      "reportContent": _reportContentController.text,
      "patientid": patientId,
    });

    try {
      var response = await DioService().dio.post(
            'https://electronicmindofalzheimerpatients.azurewebsites.net/Caregiver/CreateReport',
            data: data,
            options: Options(headers: {'Content-Type': 'application/json'}),
          );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report submitted successfully!'.tr())),
        );

        // Navigate to MainPageCaregiver upon successful report submission
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => mainpagecaregiver()), // Navigate to MainPageCaregiver
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report.'.tr())),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'Error submitting report: '.tr()} $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            // Navigate to the main caregiver page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => mainpagecaregiver()), // Use the correct route
            );
          },
        ),
      ),
      body: Background(
        SingleChildScrollView: null,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Text(
                    'Create Report'.tr(),
                    style: TextStyle(
                      fontSize: 47.0,
                      fontFamily: 'LilitaOne',
                      color: Color.fromARGB(255, 77, 125, 221),
                    ),
                  ),
                  const SizedBox(height: 80),
                  Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Date Range'.tr(),
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'dubai',
                              color: Color.fromARGB(255, 171, 194, 240),
                            ),
                          ),
                          const SizedBox(height: 13.0),
                          Row(
                            children: <Widget>[
                              _buildDateButton('Start Date', _fromDateController),
                              const SizedBox(width: 10.0),
                              _buildDateButton('End Date', _toDateController),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Report Content'.tr(),
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'dubai',
                              color: Color.fromARGB(255, 171, 194, 240),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          TextFormField(
                            controller: _reportContentController,
                            decoration: InputDecoration(
                              hintText: 'Enter the details of the report here'.tr(),
                              hintStyle: TextStyle(
                                  color: Color.fromARGB(255, 174, 170, 170),
                                  fontFamily: 'dubai'),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 15.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 84, 134, 235),
                                    width: 2.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            maxLines: null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text'.tr();
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: _submitReport,
                    child: const Text(
                      'Submit Report',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Acme'),
                    ).tr(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 73, 173, 83),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
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
