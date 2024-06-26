import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void handleSignUp({
  required BuildContext context,
  required TextEditingController fullNameController,
  required TextEditingController emailController,
  required TextEditingController passwordController,
  required TextEditingController confirmPasswordController,
  required TextEditingController phoneNumberController,
  required TextEditingController ageController,
  required VoidCallback navigateToMainPage,
}) {
  if (fullNameController.text.isNotEmpty &&
      emailController.text.isNotEmpty &&
      passwordController.text.isNotEmpty &&
      confirmPasswordController.text.isNotEmpty &&
      phoneNumberController.text.isNotEmpty &&
      ageController.text.isNotEmpty) {
    if (passwordController.text == confirmPasswordController.text) {
      navigateToMainPage();
      displaySuccessMessage(context,
          'User was successfully created! Please verify your email before Login'.tr());
    } else {
      displayErrorSnackBar(context, 'Passwords do not match'.tr());
    }
  } else {
    displayErrorSnackBar(context, 'Please fill in all fields'.tr());
  }
}

void displayErrorSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(
      message,
      textAlign: TextAlign.center,
    ),
    backgroundColor: Colors.red,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void displaySuccessMessage(BuildContext context, String message) {
  Timer? timer;
  // _timer?.cancel();
  timer = Timer(const Duration(milliseconds: 20), () {
    displaySuccessSnackBar(context, message);
  });
}

void displaySuccessSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(
      message,
      textAlign: TextAlign.center,
    ),
    backgroundColor: Colors.green,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
