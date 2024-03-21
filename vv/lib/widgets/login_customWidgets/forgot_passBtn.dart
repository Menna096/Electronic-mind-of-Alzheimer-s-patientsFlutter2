import 'package:flutter/material.dart';
import 'package:vv/Family/ForgotPasswordfamily.dart';

class forgotPassBtn extends StatelessWidget {
  const forgotPassBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 1, top: 0.5),
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ForgotPasswordfamily()),
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
    );
  }
}
