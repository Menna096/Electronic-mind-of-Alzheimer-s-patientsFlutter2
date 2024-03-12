import 'package:flutter/material.dart';
import 'package:vv/Caregiver/LoginPagecaregiver/LoginPagecaregiver.dart';
import 'package:vv/Caregiver/Verificationcaregiver/Verificationcaregiver.dart';

class ForgotPasswordcaregiver extends StatefulWidget {
  @override
  _ForgotPasswordcaregiverState createState() => _ForgotPasswordcaregiverState();
}

class _ForgotPasswordcaregiverState extends State<ForgotPasswordcaregiver> {
  TextEditingController _emailController = TextEditingController();
  String _emailError = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,//sadasdasdas
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
            SizedBox(height: 45),
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
                            builder: (context) => LoginPagecaregiver(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.5),
            Padding(
              padding: const EdgeInsets.only(left: 35.0),
              child: Text(
                'Forgot Password',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 13),
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
              padding: const EdgeInsets.only(left: 35.0, top: 30),
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
              padding:
                  EdgeInsets.only(left: 30.0, right: 30), // Adjust left padding as needed
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
            SizedBox(height: 60),
            Padding(
              padding: EdgeInsets.only(left: 30.0, right: 30),
              child: ElevatedButton(
                onPressed: () {
                  if (_emailController.text.isEmpty) {
                    setState(() {
                      _emailError = 'Please enter your email.';
                    });
                  } else {
                    // Reset the error message
                    setState(() {
                      _emailError = '';
                    });

                    // Continue with the logic for sending OTP
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Verificationcaregiver(),
                      ),
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
                  'Send OTP',
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
