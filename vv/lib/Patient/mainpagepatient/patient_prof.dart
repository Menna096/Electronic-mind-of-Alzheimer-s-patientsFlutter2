import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/widgets/background.dart';

class PatientProfManage extends StatefulWidget {
  @override
  _PatientProfManageState createState() => _PatientProfManageState();
}

class _PatientProfManageState extends State<PatientProfManage> {
  TextEditingController _fullNameController = TextEditingController();
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
          _distanceController.text =
              response.data['maximumDistance'].toString();
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
      'diagnosisDate': _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : null,
      'maximumDistance': int.parse(_distanceController.text)
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
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                controller: _fullNameController,
                readOnly: true,
              ),
              // TextFormField(
              //   decoration: InputDecoration(
              //     labelText: 'Email',
              //     prefixIcon: Icon(Icons.email),
              //   ),
              //   controller: _emailController,
              //   readOnly: true,
              // ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                controller: _phoneController,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Age',
                  prefixIcon: Icon(Icons.cake),
                ),
                controller: _ageController,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Maximum Distance',
                  prefixIcon: Icon(Icons.directions_run),
                ),
                controller: _distanceController,
              ),
              ListTile(
                title: Text(
                    'Diagnosis Date: ${_selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : "Not set"}'),
                trailing: Icon(Icons.calendar_today),
                onTap: _presentDatePicker,
              ),
              ElevatedButton(
                onPressed: updateUserProfile,
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
