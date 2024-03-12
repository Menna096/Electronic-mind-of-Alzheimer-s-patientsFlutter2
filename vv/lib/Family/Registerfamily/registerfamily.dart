import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vv/Family/LoginPagefamily/LoginPagefamily.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';

class RegisterFamily extends StatefulWidget {
  @override
  _RegisterFamilyState createState() => _RegisterFamilyState();
}

class _RegisterFamilyState extends State<RegisterFamily> {
  bool _isPasswordVisible = false;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  String _passwordErrorText = '';
  bool _isErrorDisplayed = false;

  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

  // Timer for displaying success message
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff3B5998),
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
                SizedBox(height: 10),
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
                      MaterialPageRoute(builder: (context) => LoginPagefamily()),
                    );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 0.5),
                Text(
                  'Create Account',
                  style: TextStyle(fontSize: 40, fontFamily: 'Acme'),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18),
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    suffixIcon: Icon(
                      Icons.person_2_sharp,
                      size: 25,
                      color: Color(0xFFD0D0D0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
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
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  obscureText: !_isPasswordVisible,
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
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
                    errorText: _isErrorDisplayed ? _passwordErrorText : null,
                    labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    suffixIcon: Icon(
                      Icons.phone,
                      size: 25,
                      color: Color(0xFFD0D0D0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    suffixIcon: Icon(
                      Icons.edit_attributes_rounded,
                      size: 25,
                      color: Color(0xFFD0D0D0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Check if all required fields are filled
                      if (_fullNameController.text.isNotEmpty &&
                          _emailController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty &&
                          _confirmPasswordController.text.isNotEmpty &&
                          _phoneNumberController.text.isNotEmpty &&
                          _ageController.text.isNotEmpty) {
                        // Check if password and confirm password match
                        if (_passwordController.text ==
                            _confirmPasswordController.text) {
                          // All fields are filled and passwords match, navigate to MainPageFamily
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => mainpagefamily(),
                            ),
                          );

                          // Display success message for 1000 milliseconds (1 second)
                          _displaySuccessMessage(context, 'User was successfully created! Please verify your email before Login');
                        } else {
                          // Password and confirm password do not match, show error message
                          _displayErrorSnackBar(context, 'Passwords do not match.');
                        }
                      } else {
                        // Handle invalid input case
                        _displayErrorSnackBar(context, 'Please fill in all fields.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF0386D0),
                      onPrimary: Color.fromARGB(255, 255, 255, 255),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27.0),
                      ),
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _displayErrorSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _displaySuccessMessage(BuildContext context, String message) {
    // Cancel any existing timer
    _timer?.cancel();

    // Set a timer to display the success message after a delay
    _timer = Timer(Duration(milliseconds: 20), () {
      _displaySuccessSnackBar(context, message);
    });
  }

  void _displaySuccessSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    // Dispose the timer to prevent memory leaks
    _timer?.cancel();
    super.dispose();
  }
}
