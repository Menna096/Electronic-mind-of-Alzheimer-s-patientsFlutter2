import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/custom_Textfield.dart';
import 'package:vv/widgets/pass_textField.dart';
import 'package:dio/dio.dart';

class APIService {
  static final Dio _dio = Dio();

  static Future<dynamic> register(Map<String, dynamic> userData) async {
    try {
      Response response = await _dio.post(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Authentication/Register',
        data: userData,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        // Check if there's a message field in the response data
        if (response.data != null && response.data['message'] != null) {
          return response.data['message'];
        } else {
          return 'Registration failed with status code: ${response.statusCode}';
        }
      }
    } catch (error) {
      print('Registration failed: $error');
      return 'Registration failed: $error';
    }
  }
}

class RegisterFamily extends StatefulWidget {
  @override
  _RegisterFamilyState createState() => _RegisterFamilyState();
}

class _RegisterFamilyState extends State<RegisterFamily> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  String _selectedRole = '';

  void _register(BuildContext context) async {
    // Check if password matches confirm password
    if (_passwordController.text != _confirmPasswordController.text) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Registration Failed'),
          content: Text('Password and Confirm Password do not match.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return; // Exit function if passwords don't match
    }

    // Proceed with registration
    Map<String, dynamic> userData = {
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'confirmPassword': _confirmPasswordController.text,
      'phoneNumber': _phoneNumberController.text,
      'age': _ageController.text,
      'username': _usernameController.text,
      'role': _selectedRole,
    };

    bool success = await APIService.register(userData);
    if (success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Registration Successful'),
          content: Text('You have successfully registered.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPageAll()),
                );
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Registration Failed'),
          content: Text('Registration failed. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff3B5998),
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFFFFF), Color(0xff3B5998)],
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                backbutton(),
                SizedBox(height: 0.5),
                Text(
                  'Create Account',
                  style: TextStyle(fontSize: 40, fontFamily: 'Acme'),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18),
                CustomTextField(
                  labelText: '  Full Name',
                  controller: _fullNameController,
                  suffixIcon: Icons.person_2_sharp,
                ),
                SizedBox(height: 15),
                CustomTextField(
                  labelText: '  Username',
                  controller: _usernameController,
                  suffixIcon: Icons.person_2_sharp,
                ),
                SizedBox(height: 15),
                CustomTextField(
                  labelText: '  Email Address',
                  controller: _emailController,
                  suffixIcon: Icons.email_outlined,
                ),
                SizedBox(height: 15),
                PasswordTextField(
                  labelText: '  Password',
                  controller: _passwordController,
                  suffixIcon: Icons.password_outlined,
                ),
                SizedBox(height: 15),
                PasswordTextField(
                  labelText: '  Confirm Password',
                  controller: _confirmPasswordController,
                  suffixIcon: Icons.password_outlined,
                ),
                SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedRole.isNotEmpty ? _selectedRole : null,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    }
                  },
                  items: <String>['Family', 'Caregiver']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: '  You are...',
                    labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '  Select Role', // Add hint text here
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                    // Customize hint text style if needed
                  ),
                ),
                SizedBox(height: 15),
                CustomTextField(
                  labelText: '  Phone Number',
                  controller: _phoneNumberController,
                  suffixIcon: Icons.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  labelText: '  Age',
                  controller: _ageController,
                  suffixIcon: Icons.date_range_rounded,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 60.0),
                ElevatedButton(
                  onPressed: () => _register(context),
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
