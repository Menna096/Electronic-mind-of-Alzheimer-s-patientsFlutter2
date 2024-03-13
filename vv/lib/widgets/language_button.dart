import 'package:flutter/material.dart';

class LanguageButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const LanguageButton({
    Key? key,
    required this.onPressed,
    required this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Color(0xff3B5998),
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27.0),
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff3B5998),
          ),
        ),
      ),
    );
  }
}
