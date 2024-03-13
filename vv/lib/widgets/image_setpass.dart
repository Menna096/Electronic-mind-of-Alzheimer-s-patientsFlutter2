import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
   const ImageWidget({required this.height,required this.width});

  final double height;
  final double width;
  

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(top: 0.5),
          child: Image.asset(
            'images/setpass.png', // Make sure to provide the correct image path
            width: width,
            height: height,
          ),
        ),
      ],
    );
  }
}
