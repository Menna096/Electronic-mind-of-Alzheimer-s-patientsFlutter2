import 'package:flutter/material.dart';
import 'package:vv/api/login_api.dart';

class loginButton extends StatefulWidget {
  const loginButton({super.key});

  @override
  State<loginButton> createState() => _loginButtonState();
}

class _loginButtonState extends State<loginButton> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginLogic _loginLogic = LoginLogic();
  String _errorMessage = '';
  String _emailErrorText = '';
  String _passwordErrorText = '';
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () {
          // Validate email and password before login
          if (_emailController.text.isEmpty) {
            setState(() {
              _emailErrorText = 'Please enter your email.';
            });
          } else {
            setState(() {
              _emailErrorText = '';
            });
          }

          if (_passwordController.text.isEmpty) {
            setState(() {
              _passwordErrorText = 'Please enter your password.';
            });
          } else {
            setState(() {
              _passwordErrorText = '';
            });
          }

          if (_emailController.text.isNotEmpty &&
              _passwordController.text.isNotEmpty) {
            final String email = _emailController.text;
            final String password = _passwordController.text;
            _loginLogic.login(context, email, password);
            // Call login function
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Color.fromARGB(255, 255, 255, 255),
          backgroundColor: Color(0xFF0386D0),
          fixedSize: Size(151, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27.0),
          ),
        ),
        child: Text(
          'Login',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  void _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    try {
      await _loginLogic.login(context, email, password);
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }
}
