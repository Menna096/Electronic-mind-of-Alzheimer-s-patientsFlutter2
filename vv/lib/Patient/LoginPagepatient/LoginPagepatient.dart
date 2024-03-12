import 'package:flutter/material.dart';
import 'package:vv/api/local_auth_api.dart';
import 'package:vv/my_home_page/MyHomePage.dart';
import 'package:vv/Patient/ForgotPasswordpatient/ForgotPasswordpatient.dart';
import 'package:vv/Patient/mainpagepatient/mainpagepatient.dart';

class LoginPagepatient extends StatefulWidget {
  @override
  _LoginPagepatientState createState() => _LoginPagepatientState();
}

class _LoginPagepatientState extends State<LoginPagepatient> {
  bool _isPasswordVisible = false;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  String _emailErrorText = '';
  String _passwordErrorText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 211, 46, 9),
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffFFFFFF),
              Color(0xff3B5998),
            ],
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 30),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Color.fromARGB(255, 17, 140, 212),
                        size: 40,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 60),
                Text(
                  'Welcome',
                  style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Acme'),
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
                SizedBox(height: 10),
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
                SizedBox(height: 1),
                Container(
                  margin: EdgeInsets.only(right: 1, top: 1),
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPasswordpatient()),
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
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Validate email and password before login
                    if (_emailController.text.isEmpty) {
                      setState(() {
                        _emailErrorText = 'Please enter your email.';
                      });
                    } else {
                      setState(() {
                        _emailErrorText = '';
                      });
                    }

                    if (_passwordController.text.isEmpty) {
                      setState(() {
                        _passwordErrorText = 'Please enter your password.';
                      });
                    } else {
                      setState(() {
                        _passwordErrorText = '';
                      });
                    }

                    // Only proceed with login if both email and password are not empty
                    if (_emailController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty) {
                      // Handle login logic
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF0386D0),
                    onPrimary: Color.fromARGB(255, 255, 255, 255),
                    fixedSize: Size(151, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27.0),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: 50),
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
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final isAuthenticated =
                            await LocalAuthApi.authenticate();

                        if (isAuthenticated) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => mainpagepatient()),
                          );
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 75),
                        child: Image.asset(
                          'images/fingerprint.png',
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ),
                    Image.asset(
                      'images/face-recognition.png',
                      width: 65,
                      height: 65,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
