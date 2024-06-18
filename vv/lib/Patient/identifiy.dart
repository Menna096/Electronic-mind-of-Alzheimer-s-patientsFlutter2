import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:vv/api/login_api.dart';

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _image;
  final picker = ImagePicker();
  Map<String, dynamic>? _responseData;

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _uploadImage();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage() async {
    String url =
        'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/RecognizeFaces';

    // Add your valid token here

    FormData formData = FormData.fromMap({
      'image':
          await MultipartFile.fromFile(_image!.path, filename: 'upload.jpg'),
    });

    try {
      Response response = await DioService().dio.post(
            url,
            data: formData,
          );

      // Update the response data
      setState(() {
        _responseData = response.data;
      });
    } catch (e) {
      print('Error uploading image: $e');
      // Handle token-related errors here (e.g., token expiration)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => mainpatient()),
            ); // Go back to the previous page
          },
        ),
        title: Text(
          "Identify Person",
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50.0),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView( // Wrap Column with SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Display Section
              SizedBox(height: 20),
              Center( // Center the image container
                child: Container(
                  height: 260,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                    color: Colors.grey[200],
                  ),
                  child: Center(
                    child: _responseData != null &&
                            _responseData!['imageAfterResultUrl'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              _responseData!['imageAfterResultUrl'],
                              height: 260,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                        : _image == null
                            ? Icon(Icons.image_outlined, size: 60)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  _image!,
                                  height: 260,
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Persons In Image Display
              _responseData != null &&
                      _responseData!['personsInImage'] != null
                  ? Container(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[300]!,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true, // Important for controlling height
                        physics: NeverScrollableScrollPhysics(), // Disable scrolling
                        itemCount: (_responseData!['personsInImage'] as List)
                            .length,
                        itemBuilder: (context, index) {
                          final person =
                              (_responseData!['personsInImage'] as List)[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.blueGrey[100],
                                  child: Icon(
                                    Icons.person,
                                    size: 20,
                                    color: Color.fromARGB(255, 65, 97, 202),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      person['familyName'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      person['relationalityOfThisPatient'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: getImage,
        label: Text('Select Image'),
        icon: Icon(Icons.image),
        backgroundColor: Color(0xFF6A95E9),
      ),
    );
  }
}