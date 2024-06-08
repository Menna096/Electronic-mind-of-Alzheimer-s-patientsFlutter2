import 'package:flutter/material.dart';


// ignore: camel_case_types
class ForgetPass_var_setpass_Text extends StatelessWidget {
   final String text;

  const ForgetPass_var_setpass_Text({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding:  const EdgeInsets.only(right: 18),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 35,
                
                fontFamily: 'ConcertOne',
              ),
            ),
          ),
        ],
      ),
    );
  }
}