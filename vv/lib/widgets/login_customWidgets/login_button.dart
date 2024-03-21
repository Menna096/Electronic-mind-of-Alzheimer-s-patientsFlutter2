import 'package:flutter/material.dart';
import 'package:vv/api/login.dart';

class login_button extends StatefulWidget {
  const login_button({super.key});

  @override
  State<login_button> createState() => _login_buttonState();
}

class _login_buttonState extends State<login_button> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginLogic _loginLogic = LoginLogic();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () {
          // Validate email and password before login
          if (_emailController.text.isEmpty) {
            setState(() {});
          } else {
            setState(() {});
          }

          if (_passwordController.text.isEmpty) {
            setState(() {});
          } else {
            setState(() {});
          }

          if (_emailController.text.isNotEmpty &&
              _passwordController.text.isNotEmpty) {
            _login();
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
      setState(() {});
    }
  }
}
