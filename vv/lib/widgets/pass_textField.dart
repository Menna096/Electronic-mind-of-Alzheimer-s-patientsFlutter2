import 'package:flutter/material.dart';


class PasswordTextField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final String? errorText;

  const PasswordTextField({
    Key? key,
    required this.labelText,
    required this.controller,
    this.errorText, required IconData suffixIcon,
  }) : super(key: key);

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isPasswordVisible = false;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '* Required';
    } else if (value.length < 8) {
      return 'Password should be at least 8 characters';
    } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Password should contain at least one uppercase letter';
    } else if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'Password should contain at least one lowercase letter';
    } else if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'Password should contain at least one number';
    } else if (!RegExp(r'(?=.*[@#$%^&*()_+!])').hasMatch(value)) {
      return 'Password should contain at least one special character';
    }
    return null;
  }

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
        errorText: widget.errorText ?? _validatePassword(widget.controller.text),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
      ),
      onChanged: (_) {
        setState(() {}); // Trigger revalidation on text change
      },
    );
  }
}