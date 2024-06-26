import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart'; 
import 'package:vv/Patient/mainpagepatient/vediooooo/details.dart';
import 'package:vv/Patient/mainpagepatient/vediooooo/secret_file.dart';
import 'package:vv/Patient/mainpagepatient/vediooooo/vedio.dart';
import 'package:vv/api/login_api.dart';

class SecretFilePage extends StatefulWidget {
  const SecretFilePage({super.key});

  @override
  _SecretFilePageState createState() => _SecretFilePageState();
}

class _SecretFilePageState extends State<SecretFilePage> {
  List<dynamic> secretFiles = [];
  final Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchSecretFiles();
  }

  @override
  void dispose() {
    super.dispose();
  }

  fetchSecretFiles() async {
    try {
      var response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetSecretFile');
      if (response.statusCode == 200) {
        setState(() {
          secretFiles = response.data['secretFiles'];
        });
      } else {
        print(
            'Failed to load secret files with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching data: $e');
    }
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
              MaterialPageRoute(builder: (context) => const mainpatient()),
            );
          },
        ),
        title:  Text(
          "Secret File".tr(),
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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        child: secretFiles.isEmpty
            ?  Center(
                child: Text(
                  'No Secret Files Available'.tr(),
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: secretFiles.length,
                itemBuilder: (context, index) {
                  var file = secretFiles[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => !file['needToConfirm']
                              ? DetailScreenSecret(
                                  url: file['documentUrl'],
                                  fileType: file['documentExtension'],
                                )
                              : const VideoCaptureScreen(),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              radius: 30,
                              child: Icon(
                                Icons.folder,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file['fileName'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    file['file_Description'],
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.blueAccent,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FileUploadPage(),
            ),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
