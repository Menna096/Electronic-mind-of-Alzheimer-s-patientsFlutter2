import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart';
import 'package:vv/Caregiver/mainpagecaregiver/patient_list.dart';
import 'package:vv/Family/Registerfamily/registerfamily.dart';
import 'package:vv/Family/ForgotPasswordfamily.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:vv/api/local_auth_api.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:vv/widgets/background.dart';
// Import the TokenManager class

class LoginPageAll extends StatefulWidget {
  @override
  _LoginPageAllState createState() => _LoginPageAllState();
}

class _LoginPageAllState extends State<LoginPageAll> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';
  bool _isPasswordVisible = false;
  String _emailErrorText = '';
  String _passwordErrorText = '';
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();

    _checkTokenAndEnableBiometric().then((_) {
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
      final response = await DioService().dio.post(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Authentication/Login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'];
      await TokenManager.setToken(token); // Store token using TokenManager
      print('Login successful! Token: $token');
      _handleLoginSuccess(token);
    } catch (error) {
      _showErrorDialog(
          'Login failed. Please check your credentials.'); // Show error dialog
    }
  }

  void _handleLoginSuccess(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String userRole = decodedToken['roles'];

    if (userRole == 'Family') {
      _navigateToMainPageFamily();
    } else if (userRole == 'Caregiver') {
      _navigateToMainPageCaregiver();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => mainpatient()),
      );
    }

    if (_isBiometricEnabled) {
      _authenticateWithBiometric();
    }
    _navigateBasedOnUserRole();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close the dialog
            child: Text('OK'),
          ),
        ],
      ),
    );
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
      MaterialPageRoute(builder: (context) => MainPageFamily()),
    );
  }

  void _navigateToMainPageCaregiver() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PatientListScreen()),
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
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => mainpatient()),
          );
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 110),
                Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 55,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Acme',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 60),
                _buildEmailTextField(),
                _buildPasswordTextField(),
                SizedBox(height: .5),
                _buildForgotPasswordButton(),
                SizedBox(height: .5),
                _buildLoginButton(),
                SizedBox(height: 0.5),
                _buildRegisterNowButton(),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
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
    );
  }

  Widget _buildPasswordTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
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
            color: Color.fromARGB(255, 4, 96, 150),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () {
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
          style:
              TextStyle(fontSize: 18, color: Color.fromARGB(255, 4, 96, 150)),
        ),
      ),
    );
  }

  Widget _buildRegisterNowButton() {
    return TextButton(
      onPressed: () {
        TokenManager.deleteToken();
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
}
