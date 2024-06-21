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

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainPageFamily()),
                );
              },
            ),
            title: Text(
              "Add Account",
              style: TextStyle(
                fontFamily: 'LilitaOne',
                fontSize: 23,
                color: Colors.white,
              ),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
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
            shape: RoundedRectangleBorder(
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
                          labelText: 'Full Name',
                          controller: fullNameController,
                          suffixIcon: Icons.person,
                        ),
                        const SizedBox(height: 15),
                        _buildModernTextField(
                          labelText: 'Description For Patient',
                          controller: descriptionController,
                          suffixIcon: Icons.description,
                        ),
                        const SizedBox(height: 15),
                        _buildModernTextField(
                          labelText: 'Email Address',
                          controller: emailController,
                          suffixIcon: Icons.email,
                        ),
                        const SizedBox(height: 15),
                        _buildModernTextField(
                          labelText: 'Password',
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
                          labelText: 'Confirm Password',
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
                          labelText: 'Phone Number',
                          controller: phoneNumberController,
                          suffixIcon: Icons.phone,
                        ),
                        const SizedBox(height: 15),
                        _buildModernTextField(
                          labelText: 'Age',
                          controller: ageController,
                          suffixIcon: Icons.calendar_today,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 15),
                        _buildModernTextField(
                          labelText: 'Relationality',
                          controller: relationalityController,
                          suffixIcon: Icons.group,
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
                                selectedDistance = newValue!;
                              });
                            },
                            items: distances.map((int distance) {
                              return DropdownMenuItem<int>(
                                value: distance,
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    '$distance m',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            icon: const Icon(Icons.arrow_drop_down),
                            hint: const Text('Select Maximum Distance'),
                            style: const TextStyle(
                              color: Colors.black87,
                            ),
                            dropdownColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: presentDatePicker,
                          icon: const Icon(Icons.date_range),
                          label: Text(selectedDate == null
                              ? 'Select Diagnosis Date'
                              : 'Diagnosis Date: ${DateFormat.yMMMd().format(selectedDate!)}'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            backgroundColor: Color(0xFF6A95E9),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.0),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6A95E9), Color(0xFF6A95E9)],
                              ),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  _createRoute(MapLocationPicker(
                                    apiKey:
                                        'AIzaSyCB4OrB7PgyXUrxNgf3-IZVsaHPpyt-kBM',
                                  )),
                                );

                                if (result != null) {
                                  lati = result['latitude'];
                                  long = result['longitude'];
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(15.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: const Text(
                                'Pick Location',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7.0),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 64, 202, 94),
                                  Color.fromARGB(255, 69, 181, 86)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: ElevatedButton(
                              onPressed: _Add,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(5.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : const Text(
                                      'Done',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontFamily: 'Acme'),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
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
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    VoidCallback? togglePasswordVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: labelText,
          suffixIcon: togglePasswordVisibility == null
              ? Icon(suffixIcon, color: Color(0xFF6A95E9))
              : IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Color(0xFF6A95E9),
                  ),
                  onPressed: togglePasswordVisibility,
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: Color.fromARGB(255, 69, 62, 208),
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        ),
      ),
    );
  }
}
