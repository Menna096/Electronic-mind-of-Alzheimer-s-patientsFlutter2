import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/background.dart';
import 'package:vv/widgets/text_forgot_var_set.dart';

class ForgotPasswordfamily extends StatefulWidget {
  @override
  _ForgotPasswordfamilyState createState() => _ForgotPasswordfamilyState();
}

class _ForgotPasswordfamilyState extends State<ForgotPasswordfamily> {
  final _emailController = TextEditingController(); // For email input
  final _dio = Dio(); // For network requests
  final _storage = FlutterSecureStorage(); // For sensitive data storage
  String _emailError = ''; // Error message for email input
  final _scrollController = ScrollController(); // For UI scrolling control
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // For accessing Scaffold widget
  bool _loading = false; // Track whether loading animation should be shown

  Future<void> _forgotPassword(String email) async {
    setState(() {
      _loading = true; // Show loading animation
    });
    try {
      Response response = await _dio.post(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Authentication/ForgetPassword',
        queryParameters: {'email': email},
        data: {},
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
    } on DioError catch (e) {
      // Handle specific Dio errors
      String errorMessage = 'An error occurred';
      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 400:
            errorMessage = 'No user associated with email';
            break;
          case 500:
            errorMessage = 'Server error. Please try again later';
            break;
          default:
            errorMessage = 'Unexpected error: ${e.response!.statusCode}';
            break;
        }
      } else {
        errorMessage = 'Network error. Please check your connection.';
      }
      _showDialog('Error', errorMessage, () {
        Navigator.pop(context);
      });
    } catch (e) {
      _showDialog('Error', 'An unexpected error occurred: $e', () {
        Navigator.pop(context);
      });
    } finally {
      setState(() {
        _loading = false; // Hide loading animation
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
      appBar: AppBar(
        
        elevation: 0, // Remove elevation
        leading: IconButton(
          icon: Icon(Icons.arrow_back, 
          size: 30,
          color: Color(0xff3B5998)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Background(
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
                        margin: EdgeInsets.only(right: 10, top: 30),
                        child: Image.asset(
                          'images/forgotpass.png',
                          width: 350,
                          height: 260,
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
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email Address',
                        prefixIcon: Icon(
                          Icons.email,
                          color: Color.fromARGB(255, 218, 216, 216),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
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
                              content: Text('Please Enter Your Email.'),
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
                        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 30), // Increased padding for a wider button
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Bold text and larger font size
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Larger border radius
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
          // Loading widget
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.5), // Background color
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xff3B5998),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
