import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class DioService {
  final Dio dio = Dio();

  DioService() {
    dio.options.baseUrl =
        'https://electronicmindofalzheimerpatients.azurewebsites.net';
  }
}

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
    if (_image == null) return;

    String url = '/Patient/RecognizeFaces';

    DioService dioService = DioService();

    // Add your valid token here
    String token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI4YjZjOTUxMy03YzM4LTQ0MTctOGY4YS1lNzk5OTIyMTM5OWYiLCJlbWFpbCI6InBhdGllbnQyMjk5MDBAZ21haWwuY29tIiwiRnVsbE5hbWUiOiJtZW5uYSIsIlBob25lTnVtYmVyIjoiNTY1NDMyIiwidWlkIjoiYjc0YWI5NTUtZjFlMS00ZDg3LTkzODAtZGEwYjc5ZGY4NzE0IiwiVXNlckF2YXRhciI6Imh0dHBzOi8vZWxlY3Ryb25pY21pbmRvZmFsemhlaW1lcnBhdGllbnRzLmF6dXJld2Vic2l0ZXMubmV0L1VzZXIgQXZhdGFyL2I3NGFiOTU1LWYxZTEtNGQ4Ny05MzgwLWRhMGI3OWRmODcxNF84NmExYzNjOC01MzdkLTQ0NTYtYWI5MS02NmY1MjkxYTdjZDUuanBnIiwiTWFpbkxhdGl0dWRlIjoiMjkuOTc3NjMzNSIsIk1haW5Mb25naXR1ZGUiOiIzMi41MjkwMzk1Iiwicm9sZXMiOiJQYXRpZW50IiwiTWF4RGlzdGFuY2UiOiIxIiwiZXhwIjoxNzIyMDMxNDU1LCJpc3MiOiJBcnRPZkNvZGluZyIsImF1ZCI6IkFsemhlaW1hckFwcCJ9.V69djMjrgi5a4uKFsCd91_2pc6aIwwlZntnzYncVrrQ';

    FormData formData = FormData.fromMap({
      'image':
          await MultipartFile.fromFile(_image!.path, filename: 'upload.jpg'),
    });

    try {
      Response response = await dioService.dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
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
      appBar: AppBar(
        title: Text('Image Upload Example'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _responseData != null &&
                      _responseData!['imageAfterResultUrl'] != null
                  ? Image.network(
                      _responseData!['imageAfterResultUrl'],
                      height: 260,
                      width: 200,
                    )
                  : _image == null
                      ? Text('No image selected.')
                      : Container(
                          height: 260,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          child: Image.file(_image!),
                        ),
              SizedBox(height: 20),
              _responseData != null && _responseData!['personsInImage'] != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (_responseData!['personsInImage'] as List)
                          .map((person) {
                        return Card(
                          child: ListTile(
                            title: Text(person['familyName'] ?? 'Unknown'),
                            subtitle: Text(
                                person['relationalityOfThisPatient'] ??
                                    'Unknown'),
                            trailing: Icon(Icons.person),
                          ),
                        );
                      }).toList(),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.image),
      ),
    );
  }
}
