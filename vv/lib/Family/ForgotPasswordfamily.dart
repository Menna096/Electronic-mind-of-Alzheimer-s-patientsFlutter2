import 'package:flutter/material.dart';
import 'package:vv/widgets/background.dart';
import 'package:vv/Family/Verificationfamily/Verificationfamily.dart';
import 'package:vv/widgets/text_forgot_var_set.dart';

class ForgotPasswordfamily extends StatefulWidget {
  @override
  _ForgotPasswordfamilyState createState() => _ForgotPasswordfamilyState();
}

class _ForgotPasswordfamilyState extends State<ForgotPasswordfamily> {
  TextEditingController _emailController = TextEditingController();
  String _emailError = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Background(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ForgetPass_var_setpass_Text(text: 'Forgot Password'),
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
                        builder: (context) => Verificationfamily(),
                      ),
                    );
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
