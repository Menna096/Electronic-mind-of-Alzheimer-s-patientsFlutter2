import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:vv/Patient/gpsssss/pages/google_map_page.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:vv/api/login_api.dart';
// Import the NavigationScreen

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen>
    with SingleTickerProviderStateMixin {
  File? _image;
  final picker = ImagePicker();
  Map<String, dynamic>? _responseData;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _sizeAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showPickerDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose an option".tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text("Pick from gallery".tr()),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text("Capture from camera".tr()),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

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
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    String url =
        'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/RecognizeFaces';

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
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend the body behind the AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const mainpatient()),
            ); // Go back to the previous page
          },
        ),
        title: Text(
          "Identify Person".tr(),
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
              bottom: Radius.circular(1.0),
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
      body: Stack(
        children: [
          AnimatedBackground(animationController: _animationController),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 80), // Adjust for AppBar height
                  Center(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _sizeAnimation.value,
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
                                      _responseData!['imageAfterResultUrl'] !=
                                          null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        _responseData!['imageAfterResultUrl'],
                                        height: 260,
                                        width: 200,
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  : _image == null
                                      ? const Icon(Icons.image_outlined,
                                          size: 60)
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.file(
                                            _image!,
                                            height: 260,
                                            width: 200,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                            ),
                          ),
                        );
                      },
                      child: Container(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _responseData != null &&
                          _responseData!['personsInImage'] != null
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              (_responseData!['personsInImage'] as List).length,
                          itemBuilder: (context, index) {
                            final person = (_responseData!['personsInImage']
                                as List)[index];
                            if (person['familyName'] == 'Unknown') {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.blueGrey[100],
                                          backgroundImage: NetworkImage(person[
                                              'familyAvatarUrl']), // Use the familyAvatarUrl
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Name: ${person['familyName']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              'Relation: ${person['relationalityOfThisPatient']}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              'Description: ${person['descriptionForPatient']}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              'Phone Number: ${person['familyPhoneNumber']}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacer(
                                          flex: 1,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            final latitude =
                                                person['familyLatitude'];
                                            final longitude =
                                                person['familyLongitude'];
                                            print('$latitude,$longitude');
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    NavigationScreen(
                                                        latitude, longitude),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.location_on),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPickerDialog(context),
        label: Text('Select Image'.tr()),
        icon: const Icon(Icons.image),
        backgroundColor: const Color(0xFF6A95E9),
      ),
    );
  }
}

class AnimatedBackground extends StatelessWidget {
  final AnimationController animationController;

  const AnimatedBackground({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A95E9),
                Color(0xFF38A4C0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
          child: child,
        );
      },
      child: Container(),
    );
  }
}
