import 'dart:async';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/widgets/background.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  _ViewProfileState createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _relationalityController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _diagnosisDateController =
      TextEditingController();
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
          _diagnosisDateController.text =
              DateFormat('dd-MM-yyyy', 'en').format(pickedDate);
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
          _distanceController.text = response.data['maxDistance'].toString();
          _selectedDate =
              DateFormat('dd/MM/yyyy').parse(response.data['diagnosisDate']);
          _diagnosisDateController.text =
              DateFormat('yyyy-MM-dd', 'en').format(_selectedDate!);
        });
        print('$_diagnosisDateController');
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> updateUserProfile() async {
    String apiUrl =
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/UpdatePatientProfile';

    Map<String, dynamic> requestBody = {
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'relationality': _relationalityController.text,
      'phoneNumber': _phoneController.text,
      'age': int.parse(_ageController.text),
      'maximumDistance': int.parse(_distanceController.text),
      'diagnosisDate': _selectedDate != null
          ? DateFormat('yyyy-MM-dd', 'en').format(_selectedDate!)
          : null,
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
        print('User profile updated successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User profile updated successfully'.tr()),
          ),
        );
      } else {
        print(
            'Failed to update user profile. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update user profile'.tr()),
          ),
        );
      }
    } catch (error) {
      print('An error occurred: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred'.tr()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Manage Patient Profile".tr(),
          style: TextStyle(
            fontFamily: 'LilitaOne',
            fontSize: 23,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A95E9), Color(0xFF38A4C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(8.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(66, 55, 134, 190),
                offset: Offset(0, 10),
                blurRadius: 10.0,
              ),
            ],
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50.0),
          ),
        ),
      ),
      body: Background(
        SingleChildScrollView: null,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildTextField(
                  labelText: 'Full Name'.tr(),
                  controller: _fullNameController,
                  icon: Icons.account_circle,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  labelText: 'Email'.tr(),
                  controller: _emailController,
                  icon: Icons.email,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  labelText: 'Phone Number'.tr(),
                  controller: _phoneController,
                  icon: Icons.phone,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  labelText: 'Age'.tr(),
                  controller: _ageController,
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  labelText: 'Relationality'.tr(),
                  controller: _relationalityController,
                  icon: Icons.person,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  labelText: 'Maximum Distance'.tr(),
                  controller: _distanceController,
                  icon: Icons.location_on_sharp,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: updateUserProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 64, 158, 45), // Adjust button color here
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0), // Adjust button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'Update'.tr(),
                    style: TextStyle(
                        fontSize: 18, color: Colors.white, fontFamily: 'Acme'),
                  ),
                ),
                const SizedBox(height: 30),
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
    required IconData icon,
    bool readOnly = false,
    GestureTapCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Color.fromARGB(255, 83, 83, 83), // Adjust color as needed
            fontSize: 17.0,
            fontFamily: 'Acme', // Adjust font size as needed
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
              prefixIcon:
                  Icon(icon, color: Colors.blue), // Adjust icon color as needed
            ),
          ),
        ),
      ],
    );
  }
}
