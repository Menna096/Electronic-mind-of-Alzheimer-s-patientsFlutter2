import 'package:flutter/material.dart';
import 'package:vv/Notes/views/widgets/CustomSearchIcon.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key, required this.title, this.icon, this.onPressed});
  
  final String title;
  final IconData? icon;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title ,
          style: TextStyle(
            fontSize: 38,
            fontFamily: 'PatuaOne',
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        if (icon != null) // Display the icon only if it's not null
          CustomSearchIcon(
            onPressed: onPressed,
            icon: icon!,
          ),
      ],
    );
  }
}
