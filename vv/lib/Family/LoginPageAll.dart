import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart';
import 'package:vv/Family/Registerfamily/registerfamily.dart';
import 'package:vv/Family/ForgotPasswordfamily.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/api/local_auth_api.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/background.dart';
import 'package:vv/widgets/imagefingerandface.dart';
// Import the TokenManager class

class LoginPageAll extends StatefulWidget {
  @override
  _LoginPageAllState createState() => _LoginPageAllState();
}

class _LoginPageAllState extends State<LoginPageAll> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Dio _dio = Dio();

  String _errorMessage = '';
  bool _isPasswordVisible = false;
  String _emailErrorText = '';
  String _passwordErrorText = '';
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final String? token = await TokenManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = token;
          }
          return handler.next(options);
        },
      ),
    );
    _checkTokenAndEnableBiometric().then((_) {
      // Perform biometric authentication if enabled
      if (_isBiometricEnabled) {
        _authenticateWithBiometric();
      }
    });
  }

  Future<void> _checkTokenAndEnableBiometric() async {
    final String? token = await TokenManager.getToken();
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
      await TokenManager.setToken(token); // Store token using TokenManager
      print('Login successful! Token: $token');
      _handleLoginSuccess(token);
    } catch (error) {
      _handleLoginFailure();
    }
  }

  void _handleLoginSuccess(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String userRole = decodedToken['roles'];

    if (userRole == 'Family') {
      _navigateToMainPageFamily();
    } else if (userRole == 'Caregiver') {
      _navigateToMainPageCaregiver();
    }

    if (_isBiometricEnabled) {
      _authenticateWithBiometric();
    }
    _navigateBasedOnUserRole();
  }

  void _handleLoginFailure() {
    setState(() {
      _errorMessage = 'Login failed. Please check your credentials.';
    });
  }

  Future<void> _authenticateWithBiometric() async {
    final isAuthenticated = await LocalAuthApi.authenticate();
    if (isAuthenticated) {
      _navigateBasedOnUserRole();
    } else {
      print('Fingerprint authentication failed.');
    }
  }

  void _navigateToMainPageFamily() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => mainpagefamily()),
    );
  }

  void _navigateToMainPageCaregiver() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => mainpagecaregiver()),
    );
  }

  Future<void> _navigateBasedOnUserRole() async {
    final token = await TokenManager.getToken();
    if (token != null) {
      if (token.isNotEmpty) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String userRole = decodedToken['roles'];

        if (userRole == 'Family') {
          _navigateToMainPageFamily();
        } else if (userRole == 'Caregiver') {
          _navigateToMainPageCaregiver();
        }
      }
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
              _buildEmailTextField(),
              SizedBox(height: 0),
              _buildPasswordTextField(),
              SizedBox(height: 0),
              _buildForgotPasswordButton(),
              SizedBox(height: .5),
              _buildLoginButton(),
              SizedBox(height: 0.5),
              _buildRegisterNowButton(),
              SizedBox(height: 30),
              _buildLoginWithOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTextField() {
    return TextField(
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
    );
  }

  Widget _buildPasswordTextField() {
    return TextField(
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
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            size: 25,
            color: Color(0xFFD0D0D0),
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
        errorText: _passwordErrorText,
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Container(
      margin: EdgeInsets.only(right: 1, top: 0.5),
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ForgotPasswordfamily()),
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
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
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
    );
  }

  Widget _buildRegisterNowButton() {
    return TextButton(
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
    );
  }

  Widget _buildLoginWithOptions() {
    return Column(
      children: [
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
            // Expanded(
            //   child: Align(
            //     alignment: Alignment.center,
            //     child: GestureDetector(
            //       onTap: () async {
            //         if (_isBiometricEnabled) {
            //           await _authenticateWithBiometric();
            //         } else {
            //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //             content:
            //                 Text('Biometric authentication is not enabled.'),
            //           ));
            //         }
            //       },
            //       child: Images(
            //         image: 'images/fingerprint.png',
            //         width: 70,
            //         height: 70,
            //       ),
            //     ),
            //   ),
            // ),
            Images(
              image: 'images/face-recognition.png',
              width: 65,
              height: 65,
            ),
          ],
        ),
      ],
    );
  }
}
