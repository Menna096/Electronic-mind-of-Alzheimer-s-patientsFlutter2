import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:vv/Family/Registerfamily/registerfamily.dart';
import 'package:vv/GPS/map_location_picker.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/Family/Registerfamily/profile/widgets/prof_pic.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/Family/trainingForPreson.dart';
import 'package:vv/map_location_picker.dart';
import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/custom_Textfield.dart';

// Import the second screen
class APIService {
  static final Dio _dio = Dio();

  static Future<dynamic> register(FormData formData) async {
    try {
      _dio.options.headers['accept'] = '*/*';
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
      return 'Add failed: $error';
    }
  }
}

class AddPerson extends StatefulWidget {
  const AddPerson({Key? key}) : super(key: key);

  @override
  _AddPersonState createState() => _AddPersonState();
}

class _AddPersonState extends State<AddPerson> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController descriptionForPatientController =
      TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  late String relationility = '';
  late bool _isLoading = false;
  List<File> capturedImages = [];
  // late double Latt;
  // late double Longg;

  void _add() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (fullNameController.text.isEmpty ||
          phoneNumberController.text.isEmpty ||
          relationility.isEmpty) {
        throw 'Please fill in all fields, select an image, and provide latitude and longitude.';
      }
      double Latt = double.parse(latitudeController.text);
      double Longg = double.parse(longitudeController.text);
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
        throw 'Add failed.\nSomething went wrong. Please try again later.';
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

  // Function to receive captured images from the second screen
  void receiveImages(List<File> images) {
    setState(() {
      capturedImages = images;
    });
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
                      'Create Account',
                      style: TextStyle(fontSize: 40, fontFamily: 'Acme'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    // ProfilePicture(onImageSelected: _handleImageSelected),
                    // const SizedBox(height: 18),
                    TextField(
                      controller: fullNameController,
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
                      value: relationility.isNotEmpty ? relationility : null,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            relationility = newValue;
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
                      controller: phoneNumberController,
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
                      controller: descriptionForPatientController,
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
                    // TextFormField(
                    //   controller: DescriptionForPatientontroller,
                    //   decoration: InputDecoration(
                    //     labelText: '  Description For Patient',
                    //     suffixIcon: const Icon(Icons.description),
                    //     border: const OutlineInputBorder(),
                    //     filled: true,
                    //     fillColor: Colors.white,
                    //   ),
                    //   keyboardType: TextInputType.multiline,
                    //   maxLines: 3,
                    // ),
                    const SizedBox(height: 10),
                    // ElevatedButton(
                    //   onPressed: _isLoading
                    //       ? null
                    //       : () async {
                    //           await Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => MapLocationPicker(
                    //                 apiKey:
                    //                     'AIzaSyCuTilAfnGfkZtIx0T3qf-eOmWZ_N2LpoY',
                    //                 popOnNextButtonTaped: true,
                    //                 currentLatLng:
                    //                     const LatLng(29.146727, 76.464895),
                    //                 onNext: (GeocodingResult? result) {
                    //                   if (result != null) {
                    //                     setState(() {
                    //                       Latt = result.geometry.location.lat;
                    //                       Longg = result.geometry.location.lng;
                    //                     });
                    //                   }
                    //                 },
                    //               ),
                    //             ),
                    //           );
                    //         },
                    //   style: ElevatedButton.styleFrom(
                    //     foregroundColor:
                    //         const Color.fromARGB(255, 255, 255, 255),
                    //     backgroundColor: const Color.fromARGB(255, 3, 189, 56),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(27.0),
                    //     ),
                    //   ),
                    //   child: const Text('Pick Location Here'),
                    // ),
                    TextField(
                      controller: latitudeController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: Icon(Icons.location_on, color: Colors.blue),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        height: 0.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: longitudeController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: Icon(Icons.location_on, color: Colors.blue),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        height: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        List<File>? images = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UploadImagesPagePerson(
                              fullName: fullNameController.text,
                              phoneNumber: phoneNumberController.text,
                              relation: relationility,
                              latitude:
                                  double.tryParse(latitudeController.text) ??
                                      0.0,
                              longitude:
                                  double.tryParse(longitudeController.text) ??
                                      0.0,
                              description: descriptionForPatientController.text,
                            ),
                          ),
                        );

                        if (images != null) {
                          // Handle the received images, along with the other data
                          receiveImages(images);
                        }
                      },
                      child: Text('Go to Upload Images Page'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _add,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: Color(0xFF0386D0),
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
