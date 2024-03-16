import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final String? errorText;

  const PasswordTextField({
    Key? key,
    required this.labelText,
    required this.controller,
    this.errorText,
  }) : super(key: key);

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: !_isPasswordVisible,
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        suffixIcon: InkWell(
          onTap: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          child: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            size: 25,
            color: Color(0xFFD0D0D0),
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
        errorText: widget.errorText,
      ),
    );
  }
}
