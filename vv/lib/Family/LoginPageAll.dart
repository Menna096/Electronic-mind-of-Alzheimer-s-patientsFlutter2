import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart';
import 'package:vv/Family/Registerfamily/registerfamily.dart';
import 'package:vv/api/local_auth_api.dart';
import 'package:vv/Family/ForgotPasswordfamily.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/background.dart';
import 'package:vv/widgets/imagefingerandface.dart';

class LoginPageAll extends StatefulWidget {
  @override
  _LoginPageAllState createState() => _LoginPageAllState();
}

class _LoginPageAllState extends State<LoginPageAll> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String _errorMessage = '';
  bool _isPasswordVisible = false;
  String _emailErrorText = '';
  String _passwordErrorText = '';
  final Dio _dio = Dio();
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
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
    // Check if token exists in secure storage
    _checkTokenAndEnableBiometric();
  }

  Future<void> _checkTokenAndEnableBiometric() async {
    final String? token = await _secureStorage.read(key: 'token');
    if (token != null) {
      setState(() {
        _isBiometricEnabled = true;
      });
    }
  }

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

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
      if (_isBiometricEnabled) {
        await _authenticateWithBiometric();
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Login failed. Please check your credentials.';
      });
    }
  }

  Future<void> _authenticateWithBiometric() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        SingleChildScrollView: null,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              backbutton(),
              SizedBox(height: 5),
              Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Acme',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  suffixIcon: Icon(
                    Icons.email_outlined,
                    size: 25,
                    color: Color(0xFFD0D0D0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  errorText: _emailErrorText,
                ),
              ),
              SizedBox(height: 0),
              TextField(
                obscureText: !_isPasswordVisible,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    child: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 25,
                      color: Color(0xFFD0D0D0),
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
                  errorText: _passwordErrorText,
                ),
              ),
              SizedBox(height: 0),
              Container(
                margin: EdgeInsets.only(right: 1, top: 0.5),
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPasswordfamily()),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0386D0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: .5),
              ElevatedButton(
                onPressed: () {
                  // Validate email and password before login
                  if (_emailController.text.isEmpty ||
                      _passwordController.text.isEmpty) {
                    setState(() {
                      _emailErrorText = 'Please enter your email.';
                      _passwordErrorText = 'Please enter your password.';
                    });
                    return;
                  }
                  _login();
                },
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 0.5),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterFamily(),
                    ),
                  );
                },
                child: Text(
                  'Don\'t have an account? Register Now.',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFFffffff),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: Text(
                  'Login With',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFffffff),
                    fontFamily: 'Patua One',
                  ),
                ),
              ),
              SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () async {
                          // Authenticate with biometric if enabled
                          if (_isBiometricEnabled) {
                            await _authenticateWithBiometric();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Biometric authentication is not enabled.'),
                            ));
                          }
                        },
                        child: Images(
                          image: 'images/fingerprint.png',
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ),
                  ),
                  Images(
                    image: 'images/face-recognition.png',
                    width: 65,
                    height: 65,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
