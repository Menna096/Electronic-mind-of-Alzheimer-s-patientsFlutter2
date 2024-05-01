import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:vv/utils/token_manage.dart';

class FaceLoginScreen extends StatefulWidget {
  @override
  _FaceLoginScreenState createState() => _FaceLoginScreenState();
}

class _FaceLoginScreenState extends State<FaceLoginScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    setState(() {
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _controller!.initialize();
    });
  }

  Future<void> _loginWithFaceId() async {
    if (_initializeControllerFuture != null) {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

      FormData formData = FormData.fromMap({
        'Image':
            await MultipartFile.fromFile(image.path, filename: 'upload.jpg'),
      });

      try {
        Response response = await dio.post(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Authentication/LoginWithFaceId',
          data: formData,
        );

        if (response.statusCode == 200) {
          var token = response.data['token'];
          await TokenManager.setToken(token);
          _handleLoginSuccess;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Successful')),
          );

          // Store the token securely, and navigate to the next screen
          // For example, you might use the 'flutter_secure_storage' package to store the token
          // and Navigator.pushReplacement to change screens.
        } else {
          Navigator.pushReplacementNamed(context, '/LoginPageAll');
        }
      } catch (e) {
        print(e);
        Navigator.pushReplacementNamed(context, '/LoginPageAll');
      }
    }
  }

  void _handleLoginSuccess(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String userRole = decodedToken['roles'];

    if (userRole == 'Family') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPageFamily()),
      );
    } else if (userRole == 'Caregiver') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => mainpagecaregiver()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => mainpatient()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login with Face ID')),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  _controller != null) {
                return CameraPreview(_controller!);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          Align(
            alignment: Alignment.center,
            // child: Image.asset(
            //   'images/2639811_face_id_icon.png', // Change to your image asset
            //   width: MediaQuery.of(context).size.width *
            //       0.8, // Adjust size as needed
            // ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera),
        onPressed: () {
          if (_initializeControllerFuture != null) {
            _loginWithFaceId();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
