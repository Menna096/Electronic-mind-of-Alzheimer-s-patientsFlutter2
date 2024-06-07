import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:vv/Caregiver/mainpagecaregiver/patient_list.dart';
import 'package:vv/Family/Registerfamily/registerfamily.dart';
import 'package:vv/Family/ForgotPasswordfamily.dart';
import 'package:vv/Family/enterimage.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:vv/api/local_auth_api.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/utils/token_manage.dart';
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
  bool _isLoading = false; // Add this to control loading state

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
    setState(() {
      _isLoading = true; // Set loading to true
    });
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
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false after the operation
      });
    }
  }

  void _handleLoginSuccess(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String userRole = decodedToken['roles'];

    if (userRole == 'Family') {
      checkTrain();
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

  Future<void> checkTrain() async {
    try {
      Response response = await DioService().dio.get(
            'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/FamilyNeedATrainingImages',
          );
      if (response.statusCode == 200) {
        bool needTraining = response.data['needATraining'];
        if (needTraining) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    UploadImagesPage()), // Replace YourScreen with your screen widget
          );
          print('need to train');
        } else {
          _navigateToMainPageFamily();
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _navigateBasedOnUserRole() async {
    final token = await TokenManager.getToken();
    if (token != null) {
      if (token.isNotEmpty) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String userRole = decodedToken['roles'];

        if (userRole == 'Family') {
          checkTrain();
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
      backgroundColor: Color(0xff3B5998),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffFFFFFF), // White
              Color(0xff3B5998), // Facebook Blue
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                SizedBox(height: 50.0),
                _buildEmailTextField(),
                
                SizedBox(height: 11), // Added space between email and password fields
                _buildPasswordTextField(),
                
                SizedBox(height: 50.0),
                _isLoading 
                    ? CircularProgressIndicator() // Show loading indicator
                    : _buildLoginButton(), 
                SizedBox(height: 10.0),
                _buildRegisterNowButton(),
                SizedBox(height: 10.0),
               _buildforgotpasswordButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        hintText: 'Email Address',
        prefixIcon: Icon(
          Icons.email,
          color: Color.fromARGB(255, 60, 111, 212),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
        errorText: _emailErrorText,
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      obscureText: !_isPasswordVisible,
      controller: _passwordController,
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: Icon(
          Icons.lock,
          color: Color.fromARGB(255, 60, 111, 212),
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Color.fromARGB(255, 229, 236, 251),
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
        errorText: _passwordErrorText,
      ),
    );
  }


  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        if (_emailController.text.isEmpty ||
            _passwordController.text.isEmpty) {
          setState(() {
            _emailErrorText = 'Please Enter Your Email.';
            _passwordErrorText = 'Please Enter Your Password.';
          });
          return;
        }
        _login();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 145.0, vertical: 15.0),
        textStyle: TextStyle(
          fontSize: 17.5,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 17, 59, 143) // Purple
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      child: Text('Login'),
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
      style: TextButton.styleFrom(
        foregroundColor: const Color.fromARGB(255, 255, 255, 255), // Set the text color to green
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          children: <TextSpan>[
            TextSpan(text: 'Don\'t have an account? ', style: TextStyle(color: Colors.white)), // White color for "Don't have an account?"
            TextSpan(
              text: ' Register Now!',
              style: TextStyle(
                fontFamily: 'Outfit',
                color: Color.fromARGB(255, 20, 66, 158), // Green color for "Register Now"
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
    Widget _buildforgotpasswordButton() {
    return TextButton(
      onPressed: () {
        TokenManager.deleteToken();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ForgotPasswordfamily(),
          ),
        );
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.white, // Set the text color to green
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          children: <TextSpan>[
            TextSpan(text: 'Help?! ', style: TextStyle(color: Colors.white)), // White color for "Don't have an account?"
            TextSpan(
              text: ' Forgot Password?',
              style: TextStyle(
                fontFamily: 'Outfit',
                color: Color.fromARGB(255, 17, 59, 143), // Green color for "Register Now"
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}