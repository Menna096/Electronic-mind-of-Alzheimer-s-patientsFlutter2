import 'package:flutter/material.dart';
import 'package:vv/utils/select_time.dart';


class TimePickerButton extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isEditing;

  const TimePickerButton({
    super.key,
    required this.controller,
    required this.label,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x200386D0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextButton(
          onPressed: () {
            // Handle button press based on editing state
            if (isEditing) {
              selectTime(context, controller);
            }
          },
          child: Text(
            '$label: ${controller.text}',
          ),
        ),
      ),
    );
  }
}
