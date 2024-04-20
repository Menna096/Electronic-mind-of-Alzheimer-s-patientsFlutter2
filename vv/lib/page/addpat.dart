import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:vv/Family/Registerfamily/profile/widgets/prof_pic.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/GPS/map_location_picker.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/map_location_picker.dart';
import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/custom_Textfield.dart';
import 'package:vv/widgets/pass_textField.dart';

class APIService {
  static final Dio _dio = Dio();

  static Future<dynamic> Add(FormData formData) async {
    try {
      DioService().dio.options.headers['accept'] = '/';
      DioService().dio.options.headers['content-type'] = 'multipart/form-data';
      Response response = await DioService().dio.post(
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

  // ignore: non_constant_identifier_names
  late double Lati = 0.0;
  // ignore: non_constant_identifier_names
  late double Long = 0.0;
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
        'relationality': relationalityController.text,
        'diagnosisDate': selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
            : null,
        'maxDistance': int.parse(distanceController.text),
        'longitude': Long,
        'latitude': Lati,
      });

      dynamic response = await APIService.Add(formData);

      if (response == true) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Add Successful'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => mainpagefamily()),
                  );
                },
                child: const Text('OK'),
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
          title: const Text('Add Failed'),
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
                      'Add Account',
                      style: TextStyle(fontSize: 40, fontFamily: 'Acme'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    ProfilePicture(onImageSelected: _handleImageSelected),
                    const SizedBox(height: 18),
                    CustomTextField(
                      labelText: '  Full Name',
                      controller: fullNameController,
                      suffixIcon: Icons.person_2_sharp,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      labelText: '  Email Address',
                      controller: emailController,
                      suffixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 15),
                    PasswordTextField(
                      labelText: '  Password',
                      controller: passwordController,
                      suffixIcon: Icons.password_outlined,
                    ),
                    const SizedBox(height: 15),
                    PasswordTextField(
                      labelText: '  Confirm Password',
                      suffixIcon: Icons.password_outlined,
                      controller: confirmPasswordController,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      labelText: '  Phone Number',
                      controller: phoneNumberController,
                      suffixIcon: Icons.phone,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: '  Age',
                      controller: ageController,
                      suffixIcon: Icons.date_range_rounded,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      labelText: '  relationality',
                      controller: relationalityController,
                      suffixIcon: Icons.phone,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Diagnosis Date',
                        labelStyle: const TextStyle(color: Color(0xFFa7a7a7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today,
                            size: 25, color: Color(0xFFD0D0D0)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12),
                      ),
                      controller: TextEditingController(
                        text: selectedDate == null
                            ? ''
                            : DateFormat('yyyy-MM-dd').format(selectedDate!),
                      ),
                      readOnly: true,
                      onTap: presentDatePicker,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      labelText: '  Maximum Distance',
                      controller: distanceController,
                      suffixIcon: Icons.location_on_sharp,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
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
                                    apiKey:
                                        'AIzaSyDc7BLNnR3cQAhlKRDUgpcZYssqgDIHWxc',
                                    popOnNextButtonTaped: true,
                                    currentLatLng:
                                        const LatLng(29.146727, 76.464895),
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
                        foregroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: const Color.fromARGB(255, 3, 189, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27.0),
                        ),
                      ),
                      child: const Text('Pick location'),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _Add,
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: const Color(0xFF0386D0),
                        fixedSize: const Size(151, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27.0),
                        ),
                      ),
                      child: const Text('Add'),
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
