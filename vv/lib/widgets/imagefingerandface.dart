import 'package:flutter/material.dart';

class Images extends StatelessWidget {
  const Images({required this.image, required this.height, required this.width});

  final String image; 
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 75),
      child: Image.asset(
        image,
        width: width,
        height: height,
      ),
    );
  }
}
