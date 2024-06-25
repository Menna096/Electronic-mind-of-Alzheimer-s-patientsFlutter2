import 'dart:async';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/faceid.dart';

class ImageItem {
  XFile file;
  bool isVisible;

  ImageItem({required this.file, this.isVisible = true});
}

class UploadImagesPage extends StatefulWidget {
  const UploadImagesPage({super.key});

  @override
  _UploadImagesPageState createState() => _UploadImagesPageState();
}

class _UploadImagesPageState extends State<UploadImagesPage> {
  final ImagePicker _picker = ImagePicker();
  final List<ImageItem> _images = [];
  final Dio _dio = Dio(); // Instance of Dio
  List<dynamic> _imageSamplesWithInstructions = [];

  Future<void> _fetchImagesWithInstructions() async {
    try {
      final response = await DioService().dio.get(
            'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/FamilyNeedATrainingImages',
            options: Options(
              headers: {
                'accept': '*/*',
                'Authorization': 'Bearer your_access_token_here',
              },
            ),
          );
      setState(() {
        _imageSamplesWithInstructions =
            response.data['imagesSamplesWithInstractions'];
      });
    } catch (e) {
      print('Error fetching images and instructions: $e');
    }
  }

  Future<void> _pickImage({int? replaceIndex}) async {
    if (replaceIndex != null ||
        _images.length < _imageSamplesWithInstructions.length) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
          'instructionsForImage'.tr(args: ['${replaceIndex! + 1}']),),
            content: FutureBuilder(
              future: _fetchInstructionData(replaceIndex),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SpinKitCircle(
                      color: Colors.blue, // Adjust color as needed
                      size: 50.0, // Adjust size as needed
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error fetching instructions: ${snapshot.error}');
                } else {
                  final instructionData = _imageSamplesWithInstructions[
                      replaceIndex ?? _images.length];
                  final imageUrl = instructionData['imageSampleUrl'];
                  final instruction = instructionData['instraction'];

                  return SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Image.network(imageUrl),
                        const SizedBox(height: 10),
                        Text(instruction),
                      ],
                    ),
                  );
                }
              },
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _captureImage(replaceIndex);
                },
                child: Text('Capture Image'.tr()),
              ),
            ],
          );
        },
      );
    } else {
      _captureImage(replaceIndex);
    }
  }

  Future<void> _captureImage(int? replaceIndex) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        if (replaceIndex != null) {
          _images[replaceIndex] = ImageItem(file: image);
        } else {
          _images.add(ImageItem(file: image));
        }
      });
    }
  }

  void _uploadImages() async {
    var formData = FormData();
    for (var imageItem in _images) {
      formData.files.add(MapEntry(
        'TrainingImages',
        await MultipartFile.fromFile(imageItem.file.path,
            filename: imageItem.file.name),
      ));
    }
    try {
      var response = await DioService().dio.post(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/FamilyTrainingImages',
          data: formData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Upload successful".tr()),
        backgroundColor: Colors.green,
      ));

      // Navigate to MainPageFamily on success
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainPageFamily()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error uploading images".tr()),
        backgroundColor: Colors.red,
      ));
      print('Error uploading images: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchImagesWithInstructions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: AnimatedBackground(
        child: Column(
          children: <Widget>[
            if (_images.length < _imageSamplesWithInstructions.length)
              const SizedBox(
                height: 60,
              ),
            if (_images.length < 5) // Show button only if less than 5 images
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () => _pickImage(),
                  child: Text('addImage'.tr(args: ['${_images.length + 1}'])),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0), // Adjust vertical spacing here
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Image.file(File(_images[index].file.path),
                              fit: BoxFit.cover),
                        ),
                        title: Text('imageIndex'.tr(args: ['${index + 1}']),),
                        trailing: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () => _pickImage(replaceIndex: index),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_images.length == _imageSamplesWithInstructions.length)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  onPressed: _uploadImages,
                  child: Text('Upload Images'.tr()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchInstructionData(int? replaceIndex) async {
    try {
      final response = await DioService().dio.get(
            'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/FamilyNeedATrainingImages',
            options: Options(
              headers: {
                'accept': '*/*',
                'Authorization': 'Bearer your_access_token_here',
              },
            ),
          );
      setState(() {
        _imageSamplesWithInstructions =
            response.data['imagesSamplesWithInstractions'];
      });
    } catch (e) {
      print('Error fetching images and instructions: $e');
      rethrow;
    }
  }
}
