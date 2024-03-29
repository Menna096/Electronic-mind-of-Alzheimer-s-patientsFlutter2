import 'dart:io';
import 'package:flutter/material.dart';

class PhotoScreen extends StatelessWidget {
  const PhotoScreen({super.key, required this.profileImage});
  final File profileImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Photo'),
      ),
      body: Center(
        child: Image.file(
          profileImage,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 400,
        ),
      ),
    );
  }
}
