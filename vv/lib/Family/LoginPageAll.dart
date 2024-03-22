import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vv/widgets/background.dart';
import 'package:vv/widgets/login_customWidgets/emailTextField.dart';
import 'package:vv/widgets/login_customWidgets/forgot_passBtn.dart';
import 'package:vv/widgets/login_customWidgets/login_button.dart';
import 'package:vv/widgets/login_customWidgets/login_methods.dart';
import 'package:vv/widgets/login_customWidgets/passwordTextfield.dart';
import 'package:vv/widgets/login_customWidgets/register_button.dart';

class LoginPageAll extends StatefulWidget {
  @override
  _LoginPageAllState createState() => _LoginPageAllState();
}

class _LoginPageAllState extends State<LoginPageAll> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 70),
              Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Acme',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              emailTextField(),
              passwordTextField(),
              forgotPasswordButton(),
              SizedBox(height: .5),
              loginButton(),
              SizedBox(height: 0.5),
              registerTextButton(),
              SizedBox(height: 30),
              Center(
                child: Text(
                  'Login With',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFffffff),
                    fontFamily: 'Patua One',
                  ),
                ),
              ),
              SizedBox(height: 60),
              loginMethods(),
            ],
          ),
        ),
      ),
    );
  }
}
