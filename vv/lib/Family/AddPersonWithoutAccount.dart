import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';
import 'package:vv/Family/Registerfamily/profile/widgets/prof_pic.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/custom_Textfield.dart';
import 'package:vv/map_location_picker.dart';

class APIService {
  static final Dio _dio = Dio();

  static Future<dynamic> register(FormData formData) async {
    try {
      _dio.options.headers['accept'] = '*/*';
      _dio.options.headers['content-type'] = 'multipart/form-data';
      Response response = await _dio.post(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/AddPersonWithoutAccount',
        data: formData,
      );
      return response.statusCode == 200
          ? true
          : response.data != null && response.data['message'] != null
              ? response.data['message']
              : 'Add failed with status code: ${response.data}';
    } catch (error) {
      // ignore: avoid_print
      print('Add failed: $error');
      return 'Add failed: $error';
    }
  }
}

class AddPerson extends StatefulWidget {
  const AddPerson({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddPersonState createState() => _AddPersonState();
}

class _AddPersonState extends State<AddPerson> {
  final TextEditingController FullNameController = TextEditingController();
  final TextEditingController PhoneNumberController = TextEditingController();
  final TextEditingController DescriptionForPatientontroller =
      TextEditingController();

  late String Relationility = '';
  late bool _isLoading = false;
  File? _selectedImage;
  // ignore: non_constant_identifier_names
  late double Latt;
  // ignore: non_constant_identifier_names
  late double Longg;
  Prediction? initialValue;

  void _handleImageSelected(File? image) {
    setState(() {
      _selectedImage = image;
    });
  }

  void _Add() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (FullNameController.text.isEmpty ||
          PhoneNumberController.text.isEmpty ||
          Relationility.isEmpty ||
          _selectedImage == null) {
        throw 'Please fill in all fields and select an image.';
      }

      var formData = FormData.fromMap({
        'AvatarImage': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: _selectedImage!.path.split('/').last,
          contentType: MediaType.parse(
              '${_selectedImage!.path.split('.').last == 'jpg' || _selectedImage!.path.split('.').last == 'png' ? 'image' : 'video'}/${_selectedImage!.path.split('.').last}'),
        ),
        'FullName': FullNameController.text,
        'Relationility': Relationility,
        'PhoneNumber': PhoneNumberController.text,
        'MainLongitude': Longg,
        'MainLatitude': Latt,
        'DescriptionForPatient': DescriptionForPatientontroller.text,
      });

      dynamic response = await APIService.register(formData);

      if (response == true) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Add Successful'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainPageFamily()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw 'Add failed.\nSomething Went Wrong Try Again Later ';
      }
    } catch (error) {
      showDialog(
        // ignore: use_build_context_synchronously
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
                      'Create Account',
                      style: TextStyle(fontSize: 40, fontFamily: 'Acme'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    ProfilePicture(onImageSelected: _handleImageSelected),
                    const SizedBox(height: 18),
                    TextField(
                      controller: FullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon:
                            Icon(Icons.person_2_sharp, color: Colors.blue),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        height: 0.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: Relationility.isNotEmpty ? Relationility : null,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            Relationility = newValue;
                          });
                        }
                      },
                      items: <String>[
                        'Mother',
                        'Father',
                        'Brother',
                        'Sister',
                        'Grandmother',
                        'Grandfather',
                        ' Grandson',
                        'Granddaughter',
                        'Husband',
                        'Wife',
                        'Son',
                        'Daughter',
                        'Aunt',
                        'Uncle',
                        'Niece',
                        'Nephew',
                        'Cousin',
                        'Mother-in-law',
                        'Father-in-law',
                        'Brother-in-law,',
                        'Sister-in-law',
                        'Stepfather',
                        'Stepmother',
                        'Stepbrother',
                        'Stepsister',
                        'Half-brother',
                        'Half-sister'
                      ].map<DropdownMenuItem<String>>((String value) {
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
                        hintText: '  Select Relationility',
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: PhoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: Icon(Icons.phone, color: Colors.blue),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        height: 0.5,
                      ),
                    ),
                     const SizedBox(height: 18),
                    TextFormField(
                      controller: DescriptionForPatientontroller,
                      decoration: InputDecoration(
                        labelText: 'Description For Patient',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: Icon(Icons.description, color: Colors.blue),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        height: 0.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: DescriptionForPatientontroller,
                      decoration: InputDecoration(
                        labelText: '  Description For Patient',
                        suffixIcon: const Icon(Icons.description),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
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
                                          Latt = result.geometry.location.lat;
                                          Longg = result.geometry.location.lng;
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
                      child: const Text('Pick Location Here'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _Add,
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: const Color(0xFF0386D0),
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
