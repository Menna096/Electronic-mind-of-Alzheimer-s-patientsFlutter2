import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Family/Registerfamily/profile/widgets/prof_pic.dart';
import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/custom_Textfield.dart';
import 'package:vv/widgets/pass_textField.dart';
import 'package:vv/map_location_picker.dart';

class APIService {
  static final Dio _dio = Dio();

  static Future<dynamic> register(FormData formData) async {
    try {
      _dio.options.headers['accept'] = '*/*';
      _dio.options.headers['content-type'] = 'multipart/form-data';
      Response response = await _dio.post(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Authentication/Register',
        data: formData,
      );
      return response.statusCode == 200
          ? true
          : response.data != null && response.data['message'] != null
              ? response.data['message']
              : 'Registration failed with status code: ${response.data}';
    } catch (error) {
      // ignore: avoid_print
      print('Registration failed: $error');
      return 'Registration failed: $error';
    }
  }
}

class RegisterFamily extends StatefulWidget {
  const RegisterFamily({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
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

  late String _selectedRole = '';
  late bool _isLoading = false;
  File? _selectedImage;
  // ignore: non_constant_identifier_names
  late double Lati = 0.0;
  // ignore: non_constant_identifier_names
  late double Long = 0.0;

  void _handleImageSelected(File? image) {
    setState(() {
      _selectedImage = image;
    });
  }

  void _register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_fullNameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty ||
          _phoneNumberController.text.isEmpty ||
          _ageController.text.isEmpty ||
          _selectedRole.isEmpty ||
          _selectedImage == null) {
        throw 'Please fill in all fields and select an image.';
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        throw 'Password and Confirm Password do not match.';
      }

      // Email validation using regex
      RegExp emailRegExp = RegExp(
          r'^[a-zA-Z0-9._%+-]+@(gmail\.com|yahoo\.com|outlook\.com|aol\.com|protonmail\.com|example\.com)$');
      if (!emailRegExp.hasMatch(_emailController.text)) {
        throw 'Invalid email address.\nPlease Enter Correct Email';
      }
      
      var formData = FormData.fromMap({
        'Avatar': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: _selectedImage!.path.split('/').last,
          contentType: MediaType.parse(
              '${_selectedImage!.path.split('.').last == 'jpg' || _selectedImage!.path.split('.').last == 'png' ? 'image' : 'video'}/${_selectedImage!.path.split('.').last}'),
        ),
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'role': _selectedRole,
        'phoneNumber': _phoneNumberController.text,
        'age': int.parse(_ageController.text),
        'longitude': Long,
        'latitude': Lati,
      });

      dynamic response = await APIService.register(formData);

      if (response == true) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Successful'),
            content: const Text(
                'You have Successfully Registered. Please Confirm Email To Can Login.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPageAll()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      
      } else {
        throw 'Registration failed.\nThis Email is Already registered. ';
      }
    } catch (error) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registration Failed'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff3B5998),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffFFFFFF), Color(0xff3B5998)],
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const backbutton(),
                    const SizedBox(height: 0.5),
                    const Text(
                      'Create Account',
                      style: TextStyle(fontSize: 40, fontFamily: 'Acme'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    ProfilePicture(onImageSelected: _handleImageSelected),
                    const SizedBox(height: 18),
                    CustomTextField(
                      labelText: '  Full Name',
                      controller: _fullNameController,
                      suffixIcon: Icons.person_2_sharp,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      labelText: '  Email Address',
                      controller: _emailController,
                      suffixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 15),
                    PasswordTextField(
                      labelText: '  Password',
                      controller: _passwordController,
                      suffixIcon: Icons.password_outlined,
                    ),
                    const SizedBox(height: 15),
                    PasswordTextField(
                      labelText: '  Confirm Password',
                      suffixIcon: Icons.password_outlined,
                      controller: _confirmPasswordController,
                    ),
                    const SizedBox(height: 15),
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
                        labelText: '   You are...',
                        labelStyle: const TextStyle(color: Color(0xFFa7a7a7)),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '  Select Role',
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      labelText: '  Phone Number',
                      controller: _phoneNumberController,
                      suffixIcon: Icons.phone,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: '  Age',
                      controller: _ageController,
                      suffixIcon: Icons.date_range_rounded,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapLocationPicker(
                              apiKey: 'AIzaSyDc7BLNnR3cQAhlKRDUgpcZYssqgDIHWxc',
                              popOnNextButtonTaped: true,
                              currentLatLng: const LatLng(29.146727, 76.464895),
                              onNext: (GeocodingResult? result) {
                                if (result != null) {
                                  setState(() {
                                    Lati = result.geometry.location.lat;
                                    Long = result.geometry.location.lng;
                                  });
                                }
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: const Color.fromARGB(255, 3, 189, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27.0),
                        ),
                      ),
                      child: const Text('Pick location'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: const Color(0xFF0386D0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27.0),
                        ),
                      ),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _isLoading
              ? Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xff3B5998),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
