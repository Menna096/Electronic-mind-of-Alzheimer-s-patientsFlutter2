import 'package:flutter/material.dart';

class AddTaskButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final String buttonText;
  const AddTaskButton(
      {required this.onPressed,
      required this.backgroundColor,
      required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 60),
        elevation: 4,
        backgroundColor: backgroundColor,
      ),
      child: Text(buttonText),
    );
  }
}
