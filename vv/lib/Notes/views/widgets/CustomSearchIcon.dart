import 'package:flutter/material.dart';

class CustomSearchIcon extends StatelessWidget {
   const CustomSearchIcon({Key? key, required this.icon, this.onPressed}) : super(key: key);
  
  final void Function()? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Color(0xffc4b3a8).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        onPressed:onPressed,
        icon: Center(
          child: Icon(
            icon,
            size: 28,
          ),
        ),
      ),
    );
  }
}
