import 'package:flutter/material.dart';
import 'package:vv/Family/ForgotPasswordfamily/ForgotPasswordfamily.dart';
import 'package:vv/Family/SetPasswordfamily/SetPasswordfamily.dart';

class Verificationfamily extends StatefulWidget {
  @override
  _VerificationfamilyState createState() => _VerificationfamilyState();
}

class _VerificationfamilyState extends State<Verificationfamily> {
  TextEditingController _verificationCodeController = TextEditingController();
  String _verificationCodeError = '';

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
              Color(0xffFFFFFF),
              Color(0xff3B5998),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 25),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(28.0),
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
                              builder: (context) => ForgotPasswordfamily()),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: Text(
                'Verification',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit'),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 0.4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 10, top: 1),
                  child: Image.asset(
                    'images/Verification.png',
                    width: 380,
                    height: 200,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 35.0, top: 1),
              child: Text(
                'We will send you one-time password to this email address.',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit'),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 1),
            SizedBox(height: 10),
            Padding(
              padding:
                  EdgeInsets.only(left: 30.0, right: 30), // Adjust left padding as needed
              child: TextField(
                controller: _verificationCodeController,
                decoration: InputDecoration(
                  labelText: 'example :1234',
                  labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  suffixIcon: Icon(
                    Icons.verified_user,
                    size: 25,
                    color: Color(0xFFD0D0D0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  errorText: _verificationCodeError,
                ),
              ),
            ),
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.only(left: 30.0, right: 30),
              child: ElevatedButton(
                onPressed: () {
                  if (_verificationCodeController.text.isEmpty) {
                    setState(() {
                      _verificationCodeError = 'Please enter the verification code.';
                    });
                  } else {
                    // Reset the error message
                    setState(() {
                      _verificationCodeError = '';
                    });

                    // Continue with the logic for submitting the verification code
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SetPasswordfamily()),
                    );
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
                  'Submit',
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
