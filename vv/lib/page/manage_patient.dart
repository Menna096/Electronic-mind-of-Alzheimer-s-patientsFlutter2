import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vv/api/login_api.dart';

import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/background.dart';

class viewProfile extends StatefulWidget {
  @override
  _viewProfileState createState() => _viewProfileState();
}

class _viewProfileState extends State<viewProfile> {
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _relationalityController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _distanceController = TextEditingController();
  DateTime? _selectedDate;
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
          'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/GetPatientProfile');
      if (response.statusCode == 200) {
        setState(() {
          _fullNameController.text = response.data['fullName'];
          _emailController.text = response.data['email'];
          _phoneController.text = response.data['phoneNumber'];
          _ageController.text = response.data['age'].toString();
          _relationalityController.text = response.data['relationality'];
          _selectedDate =
              DateFormat('dd/MM/yyyy').parse(response.data['diagnosisDate']);
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> updateUserProfile() async {
    // Your API endpoint URL
    String apiUrl =
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/UpdatePatientProfile';

    // Create Dio instance

    // Prepare the request body
    Map<String, dynamic> requestBody = {
      'phoneNumber': _phoneController.text,
      'age': int.parse(_ageController.text),
      'diagnosisDate': _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : null,
      'maximumDistance': _distanceController.text,
    };

    try {
      // Make the API call
      Response response = await DioService().dio.put(
            apiUrl,
            data: requestBody,
            options: Options(
              contentType: 'application/json; charset=UTF-8',
            ),
          );

      // Check if the request was successful (status code 2xx)
      if (response.statusCode == 200) {
        // Successful update
        print('User profile updated successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User profile updated successfully'),
          ),
        );
      } else {
        // Handle the error
        print(
            'Failed to update user profile. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to update user profile. Status code: ${response.statusCode}'),
          ),
        );
      }
    } catch (error) {
      // Handle any exceptions
      print('An error occurred: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        SingleChildScrollView: null,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    backbutton(),
                    // SizedBox(
                    //   height: 40,
                    // ),
                    Text(
                      'Manage Patient',
                      style: TextStyle(fontSize: 30),
                    ),
                    Text(
                      'Profile',
                      style: TextStyle(fontSize: 30),
                    )
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(90, 255, 255, 255),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        suffixIcon: Icon(Icons.account_circle,
                            size: 25, color: Color(0xFFD0D0D0)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12),
                      ),
                      readOnly: true,
                      controller: _fullNameController,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        suffixIcon: Icon(Icons.email,
                            size: 25, color: Color(0xFFD0D0D0)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12),
                      ),
                      readOnly: true,
                      controller: _emailController,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        suffixIcon: Icon(Icons.phone,
                            size: 25, color: Color(0xFFD0D0D0)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12),
                      ),
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Age',
                        labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        suffixIcon: Icon(Icons.calendar_today,
                            size: 25, color: Color(0xFFD0D0D0)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12),
                      ),
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Relationality',
                        labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        suffixIcon: Icon(Icons.person,
                            size: 25, color: Color(0xFFD0D0D0)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12),
                      ),
                      readOnly: true,
                      controller: _relationalityController,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Diagnosis Date',
                        labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        suffixIcon: Icon(Icons.calendar_today,
                            size: 25, color: Color(0xFFD0D0D0)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12),
                      ),
                      controller: TextEditingController(
                        text: _selectedDate == null
                            ? ''
                            : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                      ),
                      readOnly: true,
                      onTap: _presentDatePicker,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Maximum Distance',
                        labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        suffixIcon: Icon(Icons.location_on,
                            size: 25, color: Color(0xFFD0D0D0)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12),
                      ),
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      child: Text('Update'),
                      onPressed: () async {
                        // Call the method to update user profile
                        await updateUserProfile();
                      },
                    ),
                    SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
