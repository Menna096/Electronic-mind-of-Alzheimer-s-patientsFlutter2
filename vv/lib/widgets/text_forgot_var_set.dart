import 'package:flutter/material.dart';


class ForgetPass_var_setpass_Text extends StatelessWidget {
   final String text;

  const ForgetPass_var_setpass_Text({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 150),
          Padding(
            padding:  EdgeInsets.only(right: 18),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
          ),
        ],
      ),
    );
  }
}