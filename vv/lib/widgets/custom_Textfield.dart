import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final IconData suffixIcon;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  
  bool? readOnly;

  CustomTextField({
    super.key,
    required this.labelText,
    required this.controller,
    required this.suffixIcon,
    this.readOnly,
    this.errorText,
    this.inputFormatters,
    this.keyboardType, required BorderRadius borderRadius, required Color fillColor, required OutlineInputBorder focusedBorder, required OutlineInputBorder enabledBorder, required OutlineInputBorder border, required TextStyle textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: false,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFFa7a7a7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        suffixIcon: Icon(
          suffixIcon,
          size: 25,
          color: const Color(0xFFD0D0D0),
        ),
        filled: true,
        fillColor: Colors.white,
        errorText: errorText,
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
      ),
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
    );
  }
}
