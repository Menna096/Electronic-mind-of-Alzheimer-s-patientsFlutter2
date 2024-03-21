import 'package:flutter/material.dart';

class TaskNameTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;

  const TaskNameTextField({
    required this.controller,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            labelText: labelText), // Use labelText parameter here
      ),
    );
  }
}
