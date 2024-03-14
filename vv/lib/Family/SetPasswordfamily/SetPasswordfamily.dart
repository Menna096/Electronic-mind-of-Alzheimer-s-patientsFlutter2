import 'package:flutter/material.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/background.dart';
import 'package:vv/widgets/image_setpass.dart';

class SetPasswordfamily extends StatefulWidget {
  @override
  _SetPasswordfamilyState createState() => _SetPasswordfamilyState();
}

class _SetPasswordfamilyState extends State<SetPasswordfamily> {
  bool _isPasswordVisible = false;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _passwordErrorText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Background(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            backbutton(),

            SizedBox(height: 10),

           ImageWidget(
                    width: 175,
                    height: 175,
                  ),
            SizedBox(height: 20),
            Text(
              'Set Your Password',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'In order to keep your account safe, you need to create a strong password.',
              style: TextStyle(fontSize: 16, color: Color(0xff535252)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 30.0, right: 30),
              child: TextField(
                obscureText: !_isPasswordVisible,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 25,
                      color: Color(0xFFD0D0D0),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 30.0, right: 30),
              child: TextField(
                obscureText: !_isPasswordVisible,
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 25,
                      color: Color(0xFFD0D0D0),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  errorText: _passwordErrorText,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30, top: 40),
              child: ElevatedButton(
                onPressed: () {
                  // Add password validation logic here
                  if (_passwordController.text.isNotEmpty &&
                      _confirmPasswordController.text.isNotEmpty) {
                    if (_passwordController.text ==
                        _confirmPasswordController.text) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => mainpagefamily()),
                      );
                    } else {
                      // Handle case when passwords do not match
                      setState(() {
                        _passwordErrorText = 'Passwords do not match.';
                      });
                    }
                  } else {
                    // Handle case when one or both fields are empty
                    setState(() {
                      _passwordErrorText = 'Please fill in both fields.';
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color.fromARGB(255, 255, 255, 255), backgroundColor: Color(0xFF0386D0),
                  fixedSize: Size(100, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27.0),
                  ),
                ),
                child: Text(
                  'Next Step',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
