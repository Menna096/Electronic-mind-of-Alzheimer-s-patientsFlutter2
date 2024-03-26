import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/api/local_auth_api.dart';

class LoginApi {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final Dio _dio = Dio();

  LoginApi() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final String? token = await _secureStorage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = token;
        }
        return handler.next(options);
      },
    ));
  }

  Future<void> login(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      final response = await _dio.post(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Authentication/Login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'];
      await _secureStorage.write(key: 'token', value: token);
      print('Login successful! Token: $token');
      // Decode the JWT token
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      // Extract user's role from the decoded token
      String userRole =
          decodedToken['roles']; // Assuming the role is stored in 'role' field

      print('User role: $userRole');
      if (userRole == 'Family') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => mainpagefamily()),
        );
      } else if (userRole == 'Caregiver') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => mainpagecaregiver()),
        );
      }
    } catch (error) {
      // Handle login failure
      // Optionally, show an error message to the user
      print('Login failed. Error: $error');
    }
  }

  Future<void> authenticateWithBiometric(BuildContext context) async {
    final isAuthenticated = await LocalAuthApi.authenticate();
    if (isAuthenticated) {
      // Handle successful fingerprint authentication
      print('Fingerprint authentication successful!');

      // Decode the JWT token
      final token = await _secureStorage.read(key: 'token');
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);

      // Extract user's role from the decoded token
      String userRole = decodedToken['roles'];

      // Navigate to the appropriate page based on the user's role
      if (userRole == 'Family') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => mainpagefamily()),
        );
      } else if (userRole == 'Caregiver') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => mainpagecaregiver()),
        );
      }
    } else {
      // Handle failed fingerprint authentication
      print('Fingerprint authentication failed.');
      // Optionally, show a message to the user indicating authentication failure
    }
  }
}
