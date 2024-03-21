import 'package:flutter/material.dart';

// ignore: must_be_immutable
class loginemail extends StatelessWidget {
  loginemail({super.key});
  final TextEditingController _emailController = TextEditingController();
  String _emailErrorText = '';
  @override
  Widget build(BuildContext context) {
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
