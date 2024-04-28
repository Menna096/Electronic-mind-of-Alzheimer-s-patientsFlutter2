// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:dio/dio.dart';

// class FaceLoginScreen extends StatefulWidget {
//   @override
//   _FaceLoginScreenState createState() => _FaceLoginScreenState();
// }

// class _FaceLoginScreenState extends State<FaceLoginScreen> {
//   CameraController? _controller;
//   Future<void>? _initializeControllerFuture;
//   Dio dio = Dio();

//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//   }

//   void _initCamera() async {
//     final cameras = await availableCameras();
//     final firstCamera = cameras.first;

//     setState(() {
//       _controller = CameraController(
//         firstCamera,
//         ResolutionPreset.medium,
//       );
//       _initializeControllerFuture = _controller!.initialize();
//     });
//   }

//   Future<void> _loginWithFaceId() async {
//     if (_initializeControllerFuture != null) {
//       await _initializeControllerFuture;
//       final image = await _controller!.takePicture();

//       FormData formData = FormData.fromMap({
//         'Image': await MultipartFile.fromFile(image.path, filename: 'upload.jpg'),
//       });

//       try {
//         Response response = await dio.post(
//           'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Authentication/LoginWithFaceId',
//           data: formData,
//         );

//         if (response.statusCode == 200) {
//           var token = response.data['token']; // Adjust this to match the structure of your response
//           // Presumably, response.data will also include an 'isAuthenticated' boolean or similar

//           // Check if isAuthenticated is true, and if so, proceed to log the user in.
//           // For example:
//           // if (response.data['isAuthenticated'] == true) {
//           //   // Log the user in
//           // }

//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Login Successful')),
//           );

//           // Store the token securely, and navigate to the next screen
//           // For example, you might use the 'flutter_secure_storage' package to store the token
//           // and Navigator.pushReplacement to change screens.
//         } else {
//           Navigator.pushReplacementNamed(context, '/LoginPageAll');
//         }
//       } catch (e) {
//         print(e);
//         Navigator.pushReplacementNamed(context, '/LoginPageAll');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Login with Face ID')),
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done && _controller != null) {
//             return CameraPreview(_controller!);
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.camera),
//         onPressed: () {
//           if (_initializeControllerFuture != null) {
//             _loginWithFaceId();
//           }
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
// }
