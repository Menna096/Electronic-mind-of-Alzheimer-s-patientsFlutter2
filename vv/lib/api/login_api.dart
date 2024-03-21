import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart';
import 'package:vv/Family/mainpagefamily.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';

class LoginLogic {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final Dio _dio = Dio();

  LoginLogic() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final String? token = await _secureStorage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = token;
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<void> login(
      BuildContext context, String email, String password) async {
    try {
      final response = await _dio.post(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Authentication/Login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'];
      await _secureStorage.write(key: 'token', value: token);
      print(token);
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String userRole = decodedToken['roles'];

      _navigateToUserRole(context, userRole);
    } catch (error) {
      throw Exception('Login failed. Please check your credentials.');
    }
  }

  void _navigateToUserRole(BuildContext context, String userRole) {
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
  }
}
