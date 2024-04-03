import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Family/Registerfamily/profile/widgets/prof_pic.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/models/register.dart'; // Import your Register model
import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/custom_Textfield.dart';
import 'package:vv/widgets/pass_textField.dart';
import 'package:vv/widgets/profile.dart';
import 'package:vv/Family/Registerfamily/profile/widgets/choice_modal.dart';

class APIService {
  static final Dio _dio = Dio();

  static Future<dynamic> Add(FormData formData) async {
    try {
      _dio.options.headers['accept'] = '/';
      _dio.options.headers['content-type'] = 'multipart/form-data';
      Response response = await _dio.post(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/AddPatient',
        data: formData,
      );
      return response.statusCode == 200
          ? true
          : response.data != null && response.data['message'] != null
              ? response.data['message']
              : 'Add failed with status code: ${response.data}';
    } catch (error) {
      print('Add failed: $error');
      return 'Add failed: $error';
    }
  }
}

class Addpat extends StatefulWidget {
  @override
  _AddpatState createState() => _AddpatState();
}

class _AddpatState extends State<Addpat> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController relationalityController = TextEditingController();
  DateTime? selectedDate;
  TextEditingController distanceController = TextEditingController();
  void presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          selectedDate = pickedDate;
        });
      }
    });
  }

  bool _isLoading = false;
  File? selectedImage;

  void _handleImageSelected(File? image) {
    setState(() {
      selectedImage = image;
    });
  }

  void _Add() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (fullNameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty ||
          phoneNumberController.text.isEmpty ||
          ageController.text.isEmpty ||
          relationalityController.text.isEmpty ||
          distanceController.text.isEmpty ||
          selectedImage == null) {
        throw 'Please fill in all fields and select an image.';
      }
      if (passwordController.text != confirmPasswordController.text) {
        throw 'Password and Confirm Password do not match.';
      }

      var formData = FormData.fromMap({
        'Avatar': await MultipartFile.fromFile(
          selectedImage!.path,
          filename: selectedImage!.path.split('/').last,
          contentType: MediaType.parse(
              '${selectedImage!.path.split('.').last == 'jpg' || selectedImage!.path.split('.').last == 'png' ? 'image' : 'video'}/${selectedImage!.path.split('.').last}'),
        ),
        'fullName': fullNameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'phoneNumber': phoneNumberController.text,
        'age': int.parse(ageController.text),
        'relationality' : relationalityController.text,
        'diagnosisDate': selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : null,
        'maximumDistance': distanceController.text,
      });

      dynamic response = await APIService.Add(formData);

      if (response == true) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Add Successful'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => mainpagefamily()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw 'Add failed. Please try again. Error: $response';
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Add Failed'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
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
      backgroundColor: Color(0xff3B5998),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
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
                      'Add Account',
                      style: TextStyle(fontSize: 40, fontFamily: 'Acme'),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 18),
                    ProfilePicture(onImageSelected: _handleImageSelected),
                    SizedBox(height: 18),
                    CustomTextField(
                      labelText: '  Full Name',
                      controller: fullNameController,
                      suffixIcon: Icons.person_2_sharp,
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      labelText: '  Email Address',
                      controller: emailController,
                      suffixIcon: Icons.email_outlined,
                    ),
                    SizedBox(height: 15),
                    PasswordTextField(
                      labelText: '  Password',
                      controller: passwordController,
                      suffixIcon: Icons.password_outlined,
                    ),
                    SizedBox(height: 15),
                    PasswordTextField(
                      labelText: '  Confirm Password',
                      suffixIcon: Icons.password_outlined,
                      controller: confirmPasswordController,
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      labelText: '  Phone Number',
                      controller: phoneNumberController,
                      suffixIcon: Icons.phone,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      labelText: '  Age',
                      controller: ageController,
                      suffixIcon: Icons.date_range_rounded,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                    ),
                     SizedBox(height: 15),
                    CustomTextField(
                      labelText: '  relationality',
                      controller: relationalityController,
                      suffixIcon: Icons.phone,
                    ),
                     SizedBox(height: 15),
                    CustomTextField(
                      labelText: '  distance',
                      controller: distanceController,
                      suffixIcon: Icons.phone,
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _Add,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: Color(0xFF0386D0),
                        fixedSize: Size(151, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27.0),
                        ),
                      ),
                      child: Text('Add'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _isLoading
              ? Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xff3B5998),
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}