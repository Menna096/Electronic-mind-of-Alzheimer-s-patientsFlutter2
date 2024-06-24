import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sizer/sizer.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Family/String_manager.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart'; // Adjust path as per your project structure
// Adjust path as per your project structure
import 'package:vv/utils/token_manage.dart'; // Adjust path as per your project structure
// Import the animated background widget

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image; // Initialize as nullable
  final picker = ImagePicker();
  bool _isLoading = false; // Add a loading state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLoginDialog();
    });
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from closing on outside touch
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0.sp), // Use Sizer for border radius
          ),
          child: Container(
            padding: EdgeInsets.all(20.0.sp), // Use Sizer for padding
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0.sp), // Use Sizer for border radius
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 80.h, // Set maximum height for the dialog content
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.info_outline,
                      size: 50.sp, // Use Sizer for icon size
                      color: Colors.blue,
                    ),
                    SizedBox(height: 10.sp), // Use Sizer for spacing
                    Text(
                      context.tr(StringManager.title),
                      style: TextStyle(
                        fontSize: 20.sp, // Use Sizer for font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.sp), // Use Sizer for spacing
                    Text(
                      context.tr(StringManager.message),
                      style: TextStyle(
                        fontSize: 14.sp, // Use Sizer for font size
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.sp), // Use Sizer for spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Flexible(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0.sp), // Use Sizer for border radius
                              ),
                            ),
                            child: Text(
                              context.tr(StringManager.not_patient),
                              style: TextStyle(fontSize: 10.sp), // Use Sizer for font size
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPageAll()),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10.sp), // Use Sizer for spacing between buttons
                        Flexible(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0.sp), // Use Sizer for border radius
                              ),
                            ),
                            child: Text(
                              context.tr(StringManager.use_face_id),
                              style: TextStyle(fontSize: 10.sp), // Use Sizer for font size
                            ),
                            onPressed: () {
                              getImage();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future getImage() async {
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front, // Specify front camera
      );
      Navigator.pop(context);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          _isLoading = true; // Start loading
          uploadImage(_image!); // Automatically upload the image once it's captured
        } else {
          print('No image selected.');
          //Navigator.pushReplacement(
           // context,
            //MaterialPageRoute(builder: (context) => LoginPageAll()),
          //);
        }
      });
    } catch (e) {
      print('Error picking image: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPageAll()),
      );
    }
  }

  Future<void> uploadImage(File imageFile) async {
    String uploadUrl = "https://electronicmindofalzheimerpatients.azurewebsites.net/api/Authentication/LoginWithFaceId";
    Dio dio = Dio();

    // Get the MIME type
    String? mimeType = lookupMimeType(imageFile.path);

    mimeType ??= 'application/octet-stream';

    // Parse the MIME type into a MediaType object
    final mimeTypeData = mimeType.split('/');
    FormData formData = FormData.fromMap({
      "Image": await MultipartFile.fromFile(imageFile.path,
          filename: "image.${path.extension(imageFile.path)}", // Use the correct file extension
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1])),
    });

    try {
      Response response = await dio.post(uploadUrl, data: formData);
      final token = response.data['token'];
      await TokenManager.setToken(token);
      print('Login successful! Token: $token');
      _handleLoginSuccess(token);
      print("Upload successful, Response: ${response.data}");
    } catch (e) {
      print("Error during upload: $e");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPageAll()));
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  void _handleLoginSuccess(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String userRole = decodedToken['roles'];

    if (userRole == 'Patient') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const mainpatient()), // Adjust class name if necessary
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(
            child: Center(
              child: _image == null ? const Text('No image selected.') : Image.file(_image!),
            ),
          ),
          if (_isLoading) // Show loading indicator
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _position = -200;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {
          _position += 1;
          if (_position > 300) _position = -200;
        });
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff3B5998), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(seconds: 1),
          top: _position,
          left: -100,
          child: CircleAvatar(
            radius: 200,
            backgroundColor: Colors.white.withOpacity(0.1),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(seconds: 1),
          bottom: -_position,
          right: -100,
          child: CircleAvatar(
            radius: 200,
            backgroundColor: Colors.white.withOpacity(0.1),
          ),
        ),
        widget.child,
      ],
    );
  }
}
