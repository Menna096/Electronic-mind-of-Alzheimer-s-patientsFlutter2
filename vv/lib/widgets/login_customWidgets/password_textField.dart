import 'package:flutter/material.dart';

class loginPassword extends StatefulWidget {
  const loginPassword({super.key});

  @override
  State<loginPassword> createState() => _loginPasswordState();
}

class _loginPasswordState extends State<loginPassword> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  String _passwordErrorText = '';
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        obscureText: !_isPasswordVisible,
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Password',
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
          errorText: _passwordErrorText,
        ),
      ),
    );
  }
}
