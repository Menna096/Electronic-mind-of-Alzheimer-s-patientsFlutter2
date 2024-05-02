import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class ImageItem {
  XFile file;
  bool isVisible;

  ImageItem({required this.file, this.isVisible = true});
}

class UploadImagesPage extends StatefulWidget {
  @override
  _UploadImagesPageState createState() => _UploadImagesPageState();
}

class _UploadImagesPageState extends State<UploadImagesPage> {
  final ImagePicker _picker = ImagePicker();
  List<ImageItem> _images = [];
  int _nextImageIndex = 1;
  Dio _dio = Dio(); // Instance of Dio

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _images.add(ImageItem(file: image));
      });
      Timer(Duration(seconds: 3), () {
        setState(() {
          if (_images.length < 5) {
            _nextImageIndex++;
            for (var img in _images) {
              img.isVisible = false;
            }
          } else {
            for (var img in _images) {
              img.isVisible = true;
            }
          }
        });
      });
    }
  }

  void _uploadImages() async {
    var formData = FormData();
    for (var imageItem in _images) {
      formData.files.add(MapEntry(
        'TrainingImages',
        await MultipartFile.fromFile(imageItem.file.path, filename: imageItem.file.name),
      ));
    }

    _dio.options.headers = {
      'accept': '*/*',
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI4MDUwM2YyMi0xNmFiLTRmY2MtYWQ0Ni0wMTdiNDY1ZDkzOTEiLCJlbWFpbCI6ImZhbWlseTI1MTIwMDNAZ21haWwuY29tIiwiRnVsbE5hbWUiOiJNZW5uYS1BbGxhaCIsIlBob25lTnVtYmVyIjoiMDEyMjQ5MjAwMiIsInVpZCI6IjFkN2U5NTI0LTM1NGMtNDNkNy1iYmUwLTEzZmQzOWRiZjBlNCIsIlVzZXJBdmF0YXIiOiJodHRwczovL2VsZWN0cm9uaWNtaW5kb2ZhbHpoZWltZXJwYXRpZW50cy5henVyZXdlYnNpdGVzLm5ldC9Vc2VyIEF2YXRhci8xZDdlOTUyNC0zNTRjLTQzZDctYmJlMC0xM2ZkMzlkYmYwZTRfNGNiZjdjOWEtYjU3YS00YzQ0LTgzN2EtZjZlODcwYTkwY2IyLmpwZyIsIk1haW5MYXRpdHVkZSI6IjI5Ljk1NDc2NTYiLCJNYWluTG9uZ2l0dWRlIjoiMzIuNDk1NDY5NTAwMDAwMDA2Iiwicm9sZXMiOiJGYW1pbHkiLCJleHAiOjE3MjIzODU4NzEsImlzcyI6IkFydE9mQ29kaW5nIiwiYXVkIjoiQWx6aGVpbWFyQXBwIn0.A9CzjnQDmsfpNHNeal8VQXSiTB83X68NF78UKBMWPdc'
    };

    try {
      var response = await _dio.post(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/FamilyTrainingImages',
        data: formData
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Upload successful! Status: ${response.statusCode}"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error uploading images: $e"),
        backgroundColor: Colors.red,
      ));
      print('Error uploading images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Images'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: ElevatedButton(
                key: ValueKey<int>(_nextImageIndex),
                onPressed: _images.length < 5 ? _pickImage : null,
                child: Text(_images.length < 5 ? 'Add Image $_nextImageIndex' : 'Images Captured'),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Visibility(
                  visible: _images[index].isVisible,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      height: 100, // Height of the image
                      child: Image.file(File(_images[index].file.path)),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_images.length == 5 && _images.every((img) => img.isVisible))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: _uploadImages,
                child: Text('Upload Images'),
              ),
            ),
        ],
      ),
    );
  }
}


