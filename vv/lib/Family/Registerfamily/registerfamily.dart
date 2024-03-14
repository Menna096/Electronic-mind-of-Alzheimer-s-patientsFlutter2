import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/utils/signup_logic.dart';

import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/custom_Textfield.dart';
import 'package:vv/widgets/pass_textField.dart';
import 'package:vv/widgets/signUP_button.dart';

class RegisterFamily extends StatefulWidget {
  @override
  _RegisterFamilyState createState() => _RegisterFamilyState();
}

class _RegisterFamilyState extends State<RegisterFamily> {
  // bool _isPasswordVisible = false;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  String _passwordErrorText = '';
  bool _isErrorDisplayed = false;
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff3B5998),
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFFFFF), Color(0xff3B5998)],
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10),
                SizedBox(height: 0.5),
                Text(
                  'Create Account',
                  style: TextStyle(fontSize: 40, fontFamily: 'Acme'),
                  textAlign: TextAlign.center,
                ),
                backbutton(),
                SizedBox(height: 18),
                CustomTextField(
                  labelText: 'Full Name',
                  controller: _fullNameController,
                  suffixIcon: Icons.person_2_sharp,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  labelText: 'Email Address',
                  controller: _emailController,
                  suffixIcon: Icons.email_outlined,
                ),
                SizedBox(height: 10),
                PasswordTextField(
                  labelText: 'Password',
                  controller: _passwordController,
                ),
                SizedBox(height: 10),
                PasswordTextField(
                  labelText: 'Confirm Password',
                  controller: _confirmPasswordController,
                  errorText: _isErrorDisplayed ? _passwordErrorText : null,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  labelText: 'Phone Number',
                  controller: _phoneNumberController,
                  suffixIcon: Icons.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  labelText: 'Age',
                  controller: _ageController,
                  suffixIcon: Icons.edit_attributes_rounded,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                SignUpButton(
                  onPressed: _handleSignUp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignUp() {
    handleSignUp(
      context: context,
      fullNameController: _fullNameController,
      emailController: _emailController,
      passwordController: _passwordController,
      confirmPasswordController: _confirmPasswordController,
      phoneNumberController: _phoneNumberController,
      ageController: _ageController,
      navigateToMainPage: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => mainpagefamily(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
