import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:geolocator/geolocator.dart';

class FileUploadPage extends StatefulWidget {
  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  final Dio _dio = Dio();

  late TextEditingController _fileNameController;
  late TextEditingController _fileDescriptionController;
  late File _selectedFile = File('');

  @override
  void initState() {
    super.initState();
   
    _fileNameController = TextEditingController();
    _fileDescriptionController = TextEditingController();
  }
 
  @override
  void dispose() {
    
    _fileNameController.dispose();
    _fileDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _uploadFile() async {
    String fileName = _fileNameController.text;
    String fileDescription = _fileDescriptionController.text;

    if (fileName.isEmpty ||
        fileDescription.isEmpty ||
        _selectedFile.path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all the fields and select a file.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    String authToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI2YWFkYzQ0Ny0zM2Q0LTRmODItOTk3Mi1jNzAwYzNkOGU2NGIiLCJlbWFpbCI6InBhdGllbnQyMjk5MDBAZ21haWwuY29tIiwiRnVsbE5hbWUiOiJtZW5uYSIsIlBob25lTnVtYmVyIjoiMzM1NDMzMiIsInVpZCI6IjZmYmE4ZDg4LTk4ODAtNGZlMC1hODAwLWU5NjIyMDY1ZWNiOSIsIlVzZXJBdmF0YXIiOiJodHRwczovL2VsZWN0cm9uaWNtaW5kb2ZhbHpoZWltZXJwYXRpZW50cy5henVyZXdlYnNpdGVzLm5ldC9Vc2VyIEF2YXRhci82ZmJhOGQ4OC05ODgwLTRmZTAtYTgwMC1lOTYyMjA2NWVjYjlfNTQ0YTdhNTUtOTQ4Yi00MGVjLTkxMjMtODMxMWI0OTU3NTdiLmpwZyIsInJvbGVzIjoiUGF0aWVudCIsImV4cCI6MTcyMTAxNTEwNCwiaXNzIjoiQXJ0T2ZDb2RpbmciLCJhdWQiOiJBbHpoZWltYXJBcHAifQ.0b_MxqQnpJaSBi9QgHZX9RCx0IVRb0YYwA4kg-vIGN8';

    FormData formData = FormData.fromMap({
      'FileName': fileName,
      'File_Description': fileDescription,
      'File': await MultipartFile.fromFile(_selectedFile.path),
    });

    try {
      final response = await _dio.post(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/AddSecretFile',
        data: formData,
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $authToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('File uploaded successfully');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('File uploaded successfully'),
          backgroundColor: Colors.green,
        ));
        
        // Navigate to the "mainpatient" page here
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => mainpatient()),
        );
      } else {
        print('Failed to upload file. Error: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  void _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff3B5998),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xffFFFFFF), Color(0xff3B5998)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 30,
                  ),
                  onPressed: () {
                    // Navigate to the previous page when the back button is pressed
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(
                  height: 60,
                ),
                const Text(
                  'File Name ',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'ConcertOne',
                  ),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: _fileNameController,
                  style: const TextStyle(fontSize: 16.0),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 245, 245, 245),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                const Text(
                  'File Description ',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'ConcertOne',
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _fileDescriptionController,
                  style: const TextStyle(fontSize: 16.0),
                  maxLines: 3,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 245, 245, 245),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(
                    Icons.attach_file,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Choose File',
                    style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'LilitaOne',
                        color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 17, 143, 246),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  ),
                ),
                const SizedBox(height: 20.0),
                if (_selectedFile.path.isNotEmpty)
                  Text(
                    'Selected File: ${path.basename(_selectedFile.path)}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _uploadFile,
                  child: Center(
                    child: Text(
                      'Done',
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainPatientPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Patient Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Main Patient Page!'),
      ),
    );
  }
}