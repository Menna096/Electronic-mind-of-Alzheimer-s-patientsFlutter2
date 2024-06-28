import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:vv/Family/Registerfamily/profile/widgets/prof_pic.dart';
import 'package:vv/Family/enterimage.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/GPS/map_location_picker.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/map_location_picker.dart';

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
      return 'Add failed'.tr();
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
  final TextEditingController distanceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
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

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  List<String> relations = [
    'Mother'.tr(),
    'Father'.tr(),
    'Brother'.tr(),
    'Sister'.tr(),
    'Grandmother'.tr(),
    'Grandfather'.tr(),
    'Grandson'.tr(),
    'Granddaughter'.tr(),
    'Husband'.tr(),
    'Wife'.tr(),
    'Son'.tr(),
    'Daughter'.tr(),
    'Aunt'.tr(),
    'Uncle'.tr(),
    'Niece'.tr(),
    'Nephew'.tr(),
    'Cousin'.tr(),
    'Mother-in-law'.tr(),
    'Father-in-law'.tr(),
    'Brother-in-law'.tr(),
    'Sister-in-law'.tr(),
    'Stepfather'.tr(),
    'Stepmother'.tr(),
    'Stepbrother'.tr(),
    'Stepsister'.tr(),
    'Half-brother'.tr(),
    'Half-sister'.tr()
  ];

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
        throw 'Please fill in all fields, select an image, and choose a maximum distance'
            .tr();
      }
      if (passwordController.text != confirmPasswordController.text) {
        throw 'Password and Confirm Password do not match'.tr();
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
            ? DateFormat('yyyy-MM-dd', 'en_US').format(selectedDate!)
            : null,
        'MaximumDistance': selectedDistance,
        'MainLongitude': long,
        'MainLatitude': lati,
        'DescriptionForPatient': descriptionController.text,
      });

      // Print the form data for debugging
      print('FormData: ${formData.fields}');
      print('Files: ${formData.files}');

      dynamic response = await APIService.Add(formData);
      print('$formData');
      if (response == true) {
        await checkTrain(); // Check for training need after adding the patient
      } else {
        throw 'Add failed. Please try again'.tr();
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Add Failed'.tr()),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'.tr()),
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
            _createRoute(const UploadImagesPage()),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFFFFF), Color(0xff3B5998)],
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MainPageFamily()),
                );
              },
            ),
            title: Text(
              "Add Account".tr(),
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
                  bottom: Radius.circular(30.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: ProfilePicture(
                      onImageSelected: _handleImageSelected,
                    ),
                  ),
                  const SizedBox(height: 15),
                  buildTextField(
                    controller: fullNameController,
                    hintText: 'Full Name'.tr(),
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 10),
                  buildTextField(
                    controller: emailController,
                    hintText: 'Email'.tr(),
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  buildPasswordField(
                    controller: passwordController,
                    hintText: 'Password'.tr(),
                    icon: Icons.lock,
                    obscureText: _obscurePassword,
                    onVisibilityToggle: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  buildPasswordField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password'.tr(),
                    icon: Icons.lock,
                    obscureText: _obscureConfirmPassword,
                    onVisibilityToggle: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  buildTextField(
                    controller: phoneNumberController,
                    hintText: 'Phone Number'.tr(),
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  buildTextField(
                    controller: ageController,
                    hintText: 'Age'.tr(),
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  buildDropdownField(
                    controller: relationalityController,
                    hintText: 'Relationality'.tr(),
                    items: relations,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: presentDatePicker,
                    child: AbsorbPointer(
                      child: buildTextField(
                        controller: TextEditingController(
                          text: selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                              : '',
                        ),
                        hintText: 'Diagnosis Date'.tr(),
                        icon: Icons.calendar_today,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  buildDropdownField(
                    controller: distanceController,
                    hintText: 'Maximum Distance'.tr(),
                    items: distances.map((d) => d.toString()).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDistance = int.parse(value!);
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  buildTextField(
                    controller: descriptionController,
                    hintText: 'Description'.tr(),
                    icon: Icons.description,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapLocationPicker(
                                  apiKey:
                                      'AIzaSyCB4OrB7PgyXUrxNgf3-IZVsaHPpyt-kBM',
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
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      backgroundColor: const Color.fromARGB(255, 3, 189, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27.0),
                      ),
                    ),
                    child: Text('Pick Your location'.tr()),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _Add,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Submit'.tr(),
                              style: TextStyle(
                                fontFamily: 'LilitaOne',
                                fontSize: 20,
                              ),

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

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: onVisibilityToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget buildDropdownField({
    required TextEditingController controller,
    required String hintText,
    required List<String> items,
    ValueChanged<String?>? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: controller.text.isNotEmpty ? controller.text : null,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.arrow_drop_down),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          controller.text = value!;
        });
        if (onChanged != null) {
          onChanged(value);
        }
      },
    );
  }
}
