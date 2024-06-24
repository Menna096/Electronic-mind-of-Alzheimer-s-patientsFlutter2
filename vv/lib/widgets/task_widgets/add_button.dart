import 'package:flutter/material.dart';

class AddTaskButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final String buttonText;
  const AddTaskButton(
      {super.key, required this.onPressed,
      required this.backgroundColor,
      required this.buttonText, required RoundedRectangleBorder shape});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 60),
        elevation: 4,
        backgroundColor: backgroundColor,
        textStyle: const TextStyle(color: Colors.white),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
