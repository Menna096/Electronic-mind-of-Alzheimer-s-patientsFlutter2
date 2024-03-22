import 'package:flutter/material.dart';

class emailTextField extends StatelessWidget {
  const emailTextField({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();
    String _emailErrorText = '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'Email Address',
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
          errorText: _emailErrorText,
        ),
      ),
    );
  }
}
