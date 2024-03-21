import 'package:flutter/material.dart';

AppBar buildAppBar(String title) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: Text(
      title,
      style: TextStyle(
        color: Colors.black,
        fontSize: 30.0,
      ),
    ),
    centerTitle: true,
  );
}
