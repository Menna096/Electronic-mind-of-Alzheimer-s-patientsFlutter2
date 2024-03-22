import 'package:flutter/material.dart';
import 'package:vv/Family/Registerfamily/registerfamily.dart';

class registerTextButton extends StatelessWidget {
  const registerTextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterFamily(),
          ),
        );
      },
      child: Text(
        'Don\'t have an account? Register Now.',
        style: TextStyle(
          fontSize: 17,
          color: Color(0xFFffffff),
          fontFamily: 'Patua One',
        ),
      ),
    );
  }
}
