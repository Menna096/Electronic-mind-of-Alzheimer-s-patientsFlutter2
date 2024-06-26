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
  final TextEditingController confirmPasswordController = TextEditingController();
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
    150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900, 950, 1000
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
        throw 'Please fill in all fields, select an image, and choose a maximum distance'.tr();
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

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

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
                  MaterialPageRoute(builder: (context) => const MainPageFamily()),
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
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 25),
                        ProfilePicture(onImageSelected: _handleImageSelected),
                        const SizedBox(height: 25),
                        _buildModernTextField(
                          labelText: 'Full Name'.tr(),
                          controller: fullNameController,
                          suffixIcon: Icons.person,
                        ),
                        const SizedBox(height: 15),
                        _buildModernTextField(
                          labelText: 'Description For Patient'.tr(),
                          controller: descriptionController,
                          suffixIcon: Icons.description,
                        ),
                        const SizedBox(height: 15),
                        _buildModernTextField(
                          labelText: 'Email Address'.tr(),
                          controller: emailController,
                          suffixIcon: Icons.email,
                        ),
                        const SizedBox(height: 15),
                        _buildModernTextField(
                          labelText: 'Password'.tr(),
                          controller: passwordController,
                          suffixIcon: Icons.lock,
                          obscureText: _obscurePassword,
                          togglePasswordVisibility: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        const SizedBox(height: 15),
                        _buildModernTextField(
                          labelText: 'Confirm Password'.tr(),
                          controller: confirmPasswordController,
                          suffixIcon: Icons.lock,
                          obscureText: _obscureConfirmPassword,
                          togglePasswordVisibility: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 15),
                        _buildModernTextField(
                          labelText: 'Phone Number'.tr(),
                          controller: phoneNumberController,
                          suffixIcon: Icons.phone,
                        ),
                        const SizedBox(height: 15),
                        _buildModernTextField(
                          labelText: 'Age'.tr(),
                          controller: ageController,
                          suffixIcon: Icons.calendar_today,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.0),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 20.0),
                            ),
                            value: relationalityController.text.isEmpty ? null : relationalityController.text,
                            onChanged: (String? newValue) {
                              setState(() {
                                relationalityController.text = newValue!;
                              });
                            },
                            items: relations.map((String relation) {
                              return DropdownMenuItem<String>(
                                value: relation,
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    relation,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            icon: const Icon(Icons.arrow_drop_down),
                            hint: Text('Select Relationality'.tr()),
                            style: const TextStyle(
                              color: Colors.black87,
                            ),
                            dropdownColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.0),
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 20.0),
                            ),
                            value: selectedDistance,
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedDistance = newValue;
                              });
                            },
                            items: distances.map((int distance) {
                              return DropdownMenuItem<int>(
                                value: distance,
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    distance.toString(),
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            icon: const Icon(Icons.arrow_drop_down),
                            hint: Text('Select Maximum Distance'.tr()),
                            style: const TextStyle(
                              color: Colors.black87,
                            ),
                            dropdownColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: _Add,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 30), backgroundColor: const Color(0xFF6A95E9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            _isLoading
                                ? 'Loading...'.tr()
                                : 'Add'.tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required String labelText,
    required TextEditingController controller,
    required IconData suffixIcon,
    bool obscureText = false,
    Function()? togglePasswordVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        suffixIcon: togglePasswordVisibility != null
            ? GestureDetector(
                onTap: togglePasswordVisibility,
                child: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black54,
                ),
              )
            : Icon(
                suffixIcon,
                color: Colors.black54,
              ),
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }
}
