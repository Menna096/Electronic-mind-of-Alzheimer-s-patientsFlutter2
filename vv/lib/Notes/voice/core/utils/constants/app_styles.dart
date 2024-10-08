import 'package:flutter/material.dart';

class AppTextStyles{
  AppTextStyles._();

  static String appFont = "dubai";

  static TextStyle regular({
    double fontSize = 16,
    Color color = Colors.black,
    TextDecoration? textDecoration,
  }){
    return TextStyle(
      fontFamily: appFont,
      fontSize: fontSize,
      fontWeight:  FontWeight.w400,
      color: color,
      decoration: textDecoration,
    );
  }

  static TextStyle medium({
    double fontSize = 16,
    Color color = const Color.fromARGB(255, 197, 36, 36),
    TextDecoration? textDecoration,
    double? height
  }){
    return TextStyle(
      fontFamily: appFont,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
      decoration: textDecoration,
      height: height
    );
  }

  static TextStyle bold({
    double fontSize = 16,
    Color color = Colors.black,
    TextDecoration? textDecoration
  }){
    return TextStyle(
      fontFamily: appFont,
      fontSize: fontSize,
      fontWeight:  FontWeight.w700,
      color: color,
      decoration: textDecoration,
    );
  }
}