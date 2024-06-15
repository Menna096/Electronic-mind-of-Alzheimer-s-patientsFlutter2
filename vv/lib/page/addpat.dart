import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:vv/Family/Registerfamily/profile/widgets/prof_pic.dart';
import 'package:vv/Family/enterimage.dart';
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
              : 'Add failed with status code: ${response.statusCode}';
    } catch (error) {
      print('Add failed: $error');
      return 'Add failed: $error';
    }
  }
}

class Addpat extends StatefulWidget {
  const Addpat({super.key});

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
  TextEditingController distanceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;
  late double lati;
  late double long;
  int? selectedDistance;
  List<int> distances = [
    150,
    200,
    250,
    300,
    350,
    400,
    450,
    500,
    550,
    600,
    650,
    700,
    750,
    800,
    850,
    900,
    950,
    1000
  ];
  File? selectedImage;
  bool _isLoading = false;

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
          selectedImage == null ||
          selectedDistance == null) {
        throw 'Please fill in all fields, select an image, and choose a maximum distance.';
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
        'FullName': fullNameController.text,
        'Email': emailController.text,
        'Password': passwordController.text,
        'PhoneNumber': phoneNumberController.text,
        'Age': int.parse(ageController.text),
        'Relationality': relationalityController.text,
        'DiagnosisDate': selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
            : null,
        'MaximumDistance': selectedDistance,
        'MainLongitude': long,
        'MainLatitude': lati,
        'DescriptionForPatient': descriptionController.text,
      });

      dynamic response = await APIService.Add(formData);

      if (response == true) {
        await checkTrain(); // Check for training need after adding the patient

        // showDialog(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     title: const Text('Add Successful'),
        //     actions: [
        //       TextButton(
        //         onPressed: () {
        //           Navigator.pop(context);
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //                 builder: (context) => const MainPageFamily()),
        //           );
        //         },
        //         child: const Text('OK'),
        //       ),
        //     ],
        //   ),
        // );
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
            _createRoute(UploadImagesPage()),
          );
          print('need to train');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
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
                    const BackButton(),
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
                      labelText: 'Full Name',
                      controller: fullNameController,
                      suffixIcon: Icons.person,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description For Patient',
                        suffixIcon: const Icon(Icons.description),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      labelText: 'Email Address',
                      controller: emailController,
                      suffixIcon: Icons.email,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      // pass
                      controller: passwordController,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: confirmPasswordController,
                      //conform pass
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      labelText: 'Phone Number',
                      controller: phoneNumberController,
                      suffixIcon: Icons.phone,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      labelText: 'Age',
                      controller: ageController,
                      suffixIcon: Icons.cake,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      labelText: 'Relationality',
                      controller: relationalityController,
                      suffixIcon: Icons.group,
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Maximum Distance',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: selectedDistance,
                      items: distances.map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedDistance = newValue;
                        });
                      },
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
                                          lati = result.geometry.location.lat;
                                          long = result.geometry.location.lng;
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
