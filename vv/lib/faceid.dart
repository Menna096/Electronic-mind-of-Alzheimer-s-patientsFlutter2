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
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:vv/utils/token_manage.dart';

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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0.sp),
          ),
          child: Container(
            padding: EdgeInsets.all(20.0.sp),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0.sp),
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 80.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.info_outline,
                      size: 50.sp,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 10.sp),
                    Text(
                      context.tr(StringManager.title),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    Text(
                      context.tr(StringManager.message),
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.sp),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Flexible(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0.sp),
                              ),
                            ),
                            child: Text(
                              context.tr(StringManager.not_patient),
                              style: TextStyle(fontSize: 10.sp),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPageAll()),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10.sp),
                        Flexible(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0.sp),
                              ),
                            ),
                            child: Text(
                              context.tr(StringManager.use_face_id),
                              style: TextStyle(fontSize: 10.sp),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const CameraView()),
                              );
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
    ).then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPageAll()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(
            child: Center(
              child: Text('Welcome to the Camera Screen'),
            ),
          ),
        ],
      ),
    );
  }
}

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false;

  Future getImage() async {
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          _isLoading = true;
          uploadImage(_image!);
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

    String? mimeType = lookupMimeType(imageFile.path);
    mimeType ??= 'application/octet-stream';
    final mimeTypeData = mimeType.split('/');

    FormData formData = FormData.fromMap({
      "Image": await MultipartFile.fromFile(imageFile.path,
          filename: "image.${path.extension(imageFile.path)}",
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleLoginSuccess(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String userRole = decodedToken['roles'];

    if (userRole == 'Patient') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const mainpatient()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Face ID'.tr()),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: AnimatedBackground(
        child: Stack(
          children: [
            Center(
              child: _image == null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          'This feature is available to patients only. If you are not a patient, please go back.'
                              .tr()),
                    )
                  : Image.file(_image!),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: getImage,
                  child: Text('Open Camera'.tr()),
                ),
              ),
            ),
          ],
        ),
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
