import 'package:flutter/material.dart';

class TimeSelectionContainer extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final TimeOfDay? time;

  const TimeSelectionContainer({
    Key? key,
    required this.label,
    required this.onPressed,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Color(0x200386D0),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextButton(
          onPressed: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                time != null ? time!.format(context) : 'Select Time',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
