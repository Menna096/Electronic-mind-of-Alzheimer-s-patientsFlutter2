import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
   const ImageWidget({super.key, required this.height,required this.width});

  final double height;
  final double width;
  

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 0.5),
          child: Image.asset(
            'images/setpass.png', 
            width: width,
            height: height,
          ),
        ),
      ],
    );
  }
}
