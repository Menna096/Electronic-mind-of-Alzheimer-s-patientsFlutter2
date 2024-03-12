import 'package:flutter/material.dart';
import 'package:vv/Patient/Verificationpatient/Verificationpatient.dart';
import 'package:vv/page/home_page.dart';

class SetPasswordpatient extends StatefulWidget {
  @override
  _SetPasswordpatientState createState() => _SetPasswordpatientState();
}

class _SetPasswordpatientState extends State<SetPasswordpatient> {
  bool _isPasswordVisible = false;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _passwordErrorText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffECEFF5),
              Color(0xff3B5998),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF526CA4).withOpacity(0.2),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.grey),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Verificationpatient(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 0.5),
                  child: Image.asset(
                    'images/setpass.png',
                    width: 175,
                    height: 175,
                  ),
                ),
              ],
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
                            builder: (context) => mainpagepatient()),
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
                  primary: Color(0xFF0386D0),
                  onPrimary: Color.fromARGB(255, 255, 255, 255),
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
