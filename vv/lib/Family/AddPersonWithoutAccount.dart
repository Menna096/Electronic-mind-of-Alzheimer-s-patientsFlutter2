import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart'; // Import for input formatters
import 'package:vv/api/login_api.dart';
import 'package:vv/Family/Registerfamily/profile/widgets/prof_pic.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/map_location_picker.dart';

// Import the second screen
class APIService {
  static final Dio _dio = Dio();

  static Future<dynamic> register(FormData formData) async {
    try {
      _dio.options.headers['accept'] = '/';
      _dio.options.headers['content-type'] = 'multipart/form-data';
      Response response = await DioService().dio.post(
            'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/AddPersonWithoutAccount',
            data: formData,
          );
      return response.statusCode == 200
          ? true
          : response.data != null && response.data['message'] != null
              ? response.data['message']
              : 'Add failed with status code: ${response.data}';
    } catch (error) {
      print('Add failed: $error');
      return 'Add failed'.tr();
    }
  }
}

class AddPerson extends StatefulWidget {
  const AddPerson({super.key});

  @override
  _AddPersonState createState() => _AddPersonState();
}

class _AddPersonState extends State<AddPerson> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController descriptionForPatientController =
      TextEditingController();
  late String relationility = '';
  late bool _isLoading = false;
  List<File> capturedImages = [];
  late double Latt;
  late double Longg;

  void _add() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (fullNameController.text.isEmpty ||
          phoneNumberController.text.isEmpty ||
          relationility.isEmpty) {
        throw 'Please fill in all fields, select an image, and provide latitude and longitude'.tr();
      }

      var formData = FormData.fromMap({
        'FullName': fullNameController.text,
        'Relationility': relationility,
        'PhoneNumber': phoneNumberController.text,
        'MainLongitude': Longg,
        'MainLatitude': Latt,
        'DescriptionForPatient': descriptionForPatientController.text,
        'TraningImage': capturedImages
            .map((image) => MultipartFile.fromFileSync(image.path))
            .toList(),
      });

      dynamic response = await APIService.register(formData);

      if (response == true) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title:  Text('Add Successful'.tr()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPageFamily()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw 'Add failed.\nSomething went wrong. Please try again later.';
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title:  Text('Add Failed'.tr()),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:  Text('OK'.tr()),
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

  // Function to receive captured images from the second screen
  void receiveImages(List<File> images) {
    setState(() {
      capturedImages = images;
    });
  }
  File? selectedImage;
  void _handleImageSelected(File? image) {
    setState(() {
      selectedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "Create Account".tr(),
          style: const TextStyle(
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
              bottom: Radius.circular(10.0),
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
                    const SizedBox(height: 25),
                    ProfilePicture(onImageSelected: _handleImageSelected),
                    const SizedBox(height: 18),
                    TextField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name'.tr(),
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: const Icon(Icons.person_2_sharp, color: Colors.blue),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        height: 0.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: relationility.isNotEmpty ? relationility : null,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            relationility = newValue;
                          });
                        }
                      },
                      items: <String>[
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
                      ].map<DropdownMenuItem<String>>((String value) {
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
                        hintText: '  Select Relationility'.tr(),
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        labelText: 'Phone Number'.tr(),
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: const Icon(Icons.phone, color: Colors.blue),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        height: 0.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: descriptionForPatientController,
                      maxLines: 5, // Set max lines to 3
                      decoration: InputDecoration(
                        labelText: 'Description For Patient'.tr(),
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: const Icon(Icons.description, color: Colors.blue),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        height: 0.5,
                      ),
                    ),
                    const SizedBox(height: 15),
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
                                        'AIzaSyCB4OrB7PgyXUrxNgf3-IZVsaHPpyt-kBM',
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
                      child:  Text('Pick Location Here'.tr()),
                    ),
                    
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _add,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: const Color(0xFF0386D0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27.0),
                        ),
                      ),
                      child: Text('Add'.tr()),
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
