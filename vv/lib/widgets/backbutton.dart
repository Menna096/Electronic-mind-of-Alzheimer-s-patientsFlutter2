import 'package:flutter/material.dart';

class backbutton extends StatelessWidget {
  const backbutton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF526CA4).withOpacity(0.2),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.grey),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }
}
