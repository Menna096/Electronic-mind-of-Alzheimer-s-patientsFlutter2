import 'package:flutter/material.dart';
class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, 
    Key? key2,
    required this.title,
    required this.icon,
    this.onPressed,
    List<IconButton>? actions,
  });
  
  final String title;
  final IconData? icon;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title ,
          style: const TextStyle(
            fontSize: 38,
            fontFamily: 'PatuaOne',
            color: Color.fromARGB(255, 124, 147, 198),
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
       if (icon != null) // Display the icon only if it's not null
          GestureDetector(
            onTap: onPressed,
            child: Container(
              width: 45, // Adjust size to accommodate circular shape
              height: 45, // Adjust size to accommodate circular shape
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 124, 147, 198), // You can change color according to your design
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 25, // Adjust icon size as needed
                  color: const Color.fromARGB(255, 255, 255, 255), // You can change icon color
                ),
              ),
            ),
          ),
      ],
    );
  }
}
