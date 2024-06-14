// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:dio/dio.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart';
// import 'package:vv/Family/LoginPageAll.dart';
// import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
// import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
// import 'package:vv/utils/token_manage.dart';

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
//     final frontCamera = cameras.firstWhere(
//       (camera) => camera.lensDirection == CameraLensDirection.front,
//       orElse: () => cameras.first,
//     );

//     setState(() {
//       _controller = CameraController(
//         frontCamera,
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
//         'Image':
//             await MultipartFile.fromFile(image.path, filename: 'upload.jpg'),
//       });

//       try {
//         Response response = await dio.post(
//           'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Authentication/LoginWithFaceId',
//           data: formData,
//         );

//         if (response.statusCode == 200) {
//           var token = response.data['token'];
//           await TokenManager.setToken(token);
//           _handleLoginSuccess(token); // Pass the token to the handler
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Login Successful')),
//           );
//         } else {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => LoginPageAll()),
//           );
//         }
//       } catch (e) {
//         print(e);
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => LoginPageAll()),
//         );
//       }
//     }
//   }

//   void _handleLoginSuccess(String token) {
//     Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
//     String userRole = decodedToken['roles'];

//     if (userRole == 'Patient') {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => mainpatient()),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LoginPageAll()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Login with Face ID')),
//       body: Stack(
//         children: [
//           FutureBuilder<void>(
//             future: _initializeControllerFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.done &&
//                   _controller != null) {
//                 return CameraPreview(_controller!);
//               } else {
//                 return Center(child: CircularProgressIndicator());
//               }
//             },
//           ),
//           Align(
//             alignment: Alignment.center,
//             // child: Image.asset(
//             //   'images/2639811_face_id_icon.png', // Change to your image asset
//             //   width: MediaQuery.of(context).size.width *
//             //       0.8, // Adjust size as needed
//             // ),
//           ),
//         ],
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
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart'; // Adjust path as per your project structure
import 'package:vv/api/login_api.dart'; // Adjust path as per your project structure
import 'package:vv/utils/token_manage.dart'; // Adjust path as per your project structure

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Capture and Upload',
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
      getImage();
    });
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
        }
      });
    } catch (e) {
      print('Error picking image: $e');
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
      appBar: AppBar(
        title: Text("Camera Capture and Upload"),
      ),
      body: Center(
        child:
            _image == null ? Text('No image selected.') : Image.file(_image!),
      ),
    );
  }
}
