import 'package:flutter/material.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/widgets/background.dart';
import 'package:vv/widgets/text_forgot_var_set.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ForgotPasswordfamily extends StatefulWidget {
  @override
  _ForgotPasswordfamilyState createState() => _ForgotPasswordfamilyState();
}

class _ForgotPasswordfamilyState extends State<ForgotPasswordfamily>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController(); // For email input
  final _dio = Dio(); // For network requests
  final _storage = FlutterSecureStorage(); // For sensitive data storage
  String _emailError = ''; // Error message for email input
  final _scrollController = ScrollController(); // For UI scrolling control
  final _scaffoldKey =
      GlobalKey<ScaffoldState>(); // For accessing Scaffold widget
  double offset = 0; // Offset value

  Future<void> _forgotPassword(String email) async {
    try {
      Response response = await _dio.post(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Authentication/ForgetPassword',
        queryParameters: {'email': email},
        data: {},
        options: Options(headers: {'Accept': '/'}),
      );

      _showDialog(
        response.statusCode == 200 ? 'Success' : 'Error',
        response.statusCode == 200
            ? 'An email has been sent to $email with instructions to reset your password.'
            : 'Failed to send password recovery email.',
        response.statusCode == 200
            ? () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPageAll()),
                );
              }
            : () {
                Navigator.pop(context);
              },
      );
    } catch (e) {
      _showDialog('Error', 'An error occurred: $e', () {
        Navigator.pop(context);
      });
    }
  }

  void _showDialog(String title, String content, Function() onPressed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: onPressed,
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: Background(
        SingleChildScrollView: null,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ForgetPass_var_setpass_Text(text: 'Forgot Password'),
              SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 10, top: 10),
                    child: Image.asset(
                      'images/forgotpass.png',
                      width: 300,
                      height: 160,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.only(left: 35.0, top: 30),
                child: Text(
                  'Enter Your Email Address ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.only(left: 30.0, right: 30),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'example123@gmail.com',
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
                    errorText: _emailError,
                  ),
                ),
              ),
              SizedBox(height: 1.0),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: ElevatedButton(
                  onPressed: () {
                    String email = _emailController.text.trim();
                    if (email.isNotEmpty) {
                      _forgotPassword(email);
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Error'),
                          content: Text('Please enter your email.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF0386D0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}