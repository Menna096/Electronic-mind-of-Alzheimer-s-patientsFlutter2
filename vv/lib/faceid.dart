import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart'; // Adjust path as per your project structure
import 'package:vv/api/login_api.dart'; // Adjust path as per your project structure
import 'package:vv/utils/token_manage.dart'; // Adjust path as per your project structure
// Import the animated background widget

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image; // Initialize as nullable

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
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
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.info_outline,
                  size: 50,
                  color: Colors.blue,
                ),
                SizedBox(height: 10),
                Text(
                  "Notice",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Login with face ID is only available for patients.",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      child: Text("Not patient"),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginPageAll()),
                        );
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      child: Text("Use face ID"),
                      onPressed: () {
                        getImage();
                      },
                    ),
                  ],
                ),
              ],
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

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          uploadImage(
              _image!); // Automatically upload the image once it's captured
        } else {
          print('No image selected.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPageAll()),
          );
        }
      });
    } catch (e) {
      print('Error picking image: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPageAll()),
      );
    }
  }

  Future<void> uploadImage(File imageFile) async {
    String uploadUrl =
        "https://electronicmindofalzheimerpatients.azurewebsites.net/api/Authentication/LoginWithFaceId";
    Dio dio = Dio();

    // Get the MIME type
    String? mimeType = lookupMimeType(imageFile.path);

    if (mimeType == null) {
      mimeType = 'application/octet-stream'; // Default MIME type
    }

    // Parse the MIME type into a MediaType object
    final mimeTypeData = mimeType.split('/');
    FormData formData = FormData.fromMap({
      "Image": await MultipartFile.fromFile(imageFile.path,
          filename:
              "image.${path.extension(imageFile.path)}", // Use the correct file extension
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
    }
  }

  void _handleLoginSuccess(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String userRole = decodedToken['roles'];

    if (userRole == 'Patient') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                mainpatient()), // Adjust class name if necessary
      );
    }

    // Do not call _authenticateWithBiometric here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: Center(
          child:
              _image == null ? Text('No image selected.') : Image.file(_image!),
        ),
      ),
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({Key? key, required this.child}) : super(key: key);

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
      duration: Duration(seconds: 5),
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff3B5998), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: Duration(seconds: 1),
          top: _position,
          left: -100,
          child: CircleAvatar(
            radius: 200,
            backgroundColor: Colors.white.withOpacity(0.1),
          ),
        ),
        AnimatedPositioned(
          duration: Duration(seconds: 1),
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
