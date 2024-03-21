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
  TextEditingController _emailController = TextEditingController();
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String _emailError = '';
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double offset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void onScroll() {
    setState(() {
      offset = _scrollController.offset;
    });
  }

  Future<void> _forgotPassword(String email) async {
    try {
      String url =
          'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Authentication/ForgetPassword';

      // Define request body (empty for this case)
      Map<String, dynamic> data = {};

      // Define query parameters (email)
      Map<String, dynamic> queryParameters = {'email': email};

      // Send POST request using Dio
      Response response = await _dio.post(
        url,
        queryParameters: queryParameters,
        data: data,
        options: Options(
          headers: {'Accept': '/'},
        ),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text(
                'An email has been sent to $email with instructions to reset your password.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the success dialog
                  Navigator.pushReplacement( // Navigate to the login page
                    context,
                    MaterialPageRoute(builder: (context) => LoginPageAll()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to send password recovery email.'),
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
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred: $e'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: Background(
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
