import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Family/Registerfamily/profile/widgets/prof_pic.dart';
import 'package:vv/widgets/backbutton.dart';
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
      return 'Registration failed: $error';
    }
  }
}

class RegisterFamily extends StatefulWidget {
  const RegisterFamily({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterFamilyState createState() => _RegisterFamilyState();
}

class _RegisterFamilyState extends State<RegisterFamily> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  late String _selectedRole = '';
  late bool _isLoading = false;
  File? _selectedImage;
  double? _latitude;
  double? _longitude;
  bool _isPasswordVisible = false;

  void _handleImageSelected(File? image) {
    setState(() {
      _selectedImage = image;
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '* Required'.tr();
    } else if (value.length < 8) {
      return 'Password should be at least 8 characters'.tr();
    } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Password should contain at least one uppercase letter'.tr();
    } else if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'Password should contain at least one lowercase letter'.tr();
    } else if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'Password should contain at least one number'.tr();
    } else if (!RegExp(r'(?=.*[@#$%^&*()_+!])').hasMatch(value)) {
      return 'Password should contain at least one special character'.tr();
    }
    return null;
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_fullNameController.text.isEmpty &&
          _emailController.text.isEmpty &&
          _passwordController.text.isEmpty &&
          _confirmPasswordController.text.isEmpty &&
          _phoneNumberController.text.isEmpty &&
          _ageController.text.isEmpty &&
          _selectedRole.isEmpty &&
          _selectedImage == null &&
          _latitude == null &&
          _longitude == null) {
        throw 'Please Fill in All The Fields'.tr();
      }
       // ignore: unnecessary_null_comparison
       if (_fullNameController.text.isEmpty == null) {
        throw 'Please Choose Your Full Name'.tr();
      }
      if (
          // ignore: unnecessary_null_comparison
          _emailController.text.isEmpty == null) {
        throw 'Please Write a Email Address'.tr();
      }
      if (
          // ignore: unnecessary_null_comparison
          _passwordController.text.isEmpty == null) {
        throw 'Please Write Your Password'.tr();
      }
      if (
          // ignore: unnecessary_null_comparison
          _confirmPasswordController.text.isEmpty == null) {
        throw 'Please Write Your Confirm Password'.tr();
      }
      // ignore: unnecessary_null_comparison
      if (_phoneNumberController.text.isEmpty == null) {
        throw 'Please Write Your Phone Number'.tr();
      }
      // ignore: unnecessary_null_comparison
      if (_ageController.text.isEmpty == null) {
        throw 'Please Write Your Age'.tr();
      }
     // ignore: unnecessary_null_comparison
     if ( _selectedRole.isEmpty == null) {
        throw 'Please Choose Who You Are'.tr();
      }
     if (_selectedImage == null) {
        throw 'Please Select Your Image'.tr();
      }
      if (_latitude == null ||
          _longitude == null) {
        throw 'Please Pick Your Location'.tr();
      }
     
      if (_passwordController.text != _confirmPasswordController.text) {
        throw 'Password and Confirm Password do not match'.tr();
      }
    if (_validatePassword(_passwordController.text) != null) {
        throw _validatePassword(_passwordController.text)!;
      }

      // Email validation using regex
      RegExp emailRegExp = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$");
      if (!emailRegExp.hasMatch(_emailController.text)) {
        throw 'Invalid email address. Please enter a correct email'.tr();
      }
 
      var formData = FormData.fromMap({
        'Avatar': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: _selectedImage!.path.split('/').last,
          contentType: MediaType('application', 'octet-stream'),
        ),
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'role': _selectedRole,
        'phoneNumber': _phoneNumberController.text,
        'age': int.parse(_ageController.text),
        'mainLongitude': _longitude,
        'mainLatitude': _latitude,
      });

      dynamic response = await APIService.register(formData);

      if (response == true) {
        _showDialog('Registration Successful'.tr(), 
                    'You have Successfully Registered'.tr(), 
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPageAll()),
                      );
                    });
      } else {
        throw 'Registration failed. This Email is Already registered'.tr();
      }
    } catch (error) {
      _showDialog('Registration Failed'.tr(), error.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDialog(String title, String content, {VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: onPressed ?? () => Navigator.pop(context),
            child: Text('OK'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField(
      {required TextEditingController controller,
      required String hintText,
      required Icon prefixIcon,
      bool obscureText = false,
      Widget? suffixIcon,
      TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator,
      List<TextInputFormatter>? inputFormatters}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
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
                     Text(
                      'Create Account'.tr(),
                      style: const TextStyle(fontSize: 40, fontFamily: 'Acme'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    ProfilePicture(onImageSelected: _handleImageSelected),
                    const SizedBox(height: 18),
                    _buildTextFormField(
                      controller: _fullNameController,
                      hintText: ' Full Name'.tr(),
                      prefixIcon: const Icon(Icons.person, color: Color.fromARGB(255, 97, 149, 251),),
                    ),
                    const SizedBox(height: 15),
                    _buildTextFormField(
                      controller: _emailController,
                      hintText: '  Email Address'.tr(),
                      prefixIcon: const Icon(Icons.email, color: Color.fromARGB(255, 97, 149, 251),),
                    ),
                    const SizedBox(height: 15),
                    _buildTextFormField(
                      controller: _passwordController,
                      hintText: '  Password'.tr(),
                      prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 97, 149, 251),),
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color.fromARGB(255, 255, 244, 244),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 15),
                    _buildTextFormField(
                      controller: _confirmPasswordController,
                      hintText: '  Confirm Password'.tr(),
                      prefixIcon: const Icon(Icons.lock, color:Color.fromARGB(255, 97, 149, 251),),
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color.fromARGB(255, 255, 244, 244),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Password and Confirm Password do not match'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildTextFormField(
                      controller: _phoneNumberController,
                      hintText: '  Phone Number'.tr(),
                      prefixIcon: const Icon(Icons.phone, color: Color.fromARGB(255, 94, 142, 236),),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _ageController,
                      hintText: '  Age'.tr(),
                      prefixIcon: const Icon(Icons.date_range_rounded, color: Color.fromARGB(255, 94, 142, 236),),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                      items: <String>['Family'.tr(), 'Caregiver'.tr()]
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: '   You are...'.tr(),
                        labelStyle: const TextStyle(color: Color(0xFFa7a7a7)),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '  Select Role'.tr(),
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapLocationPicker(
                                    apiKey: 'AIzaSyCB4OrB7PgyXUrxNgf3-IZVsaHPpyt-kBM',
                                    popOnNextButtonTaped: true,
                                    currentLatLng: const LatLng(29.146727, 76.464895),
                                    onNext: (GeocodingResult? result) {
                                      if (result != null) {
                                        setState(() {
                                          _latitude = result.geometry.location.lat;
                                          _longitude = result.geometry.location.lng;
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
                      child:  Text('Pick Your location'.tr()),
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
                      child: Text('Register'.tr()),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xff3B5998),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
