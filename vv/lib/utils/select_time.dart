import 'package:flutter/material.dart';

Future<void> selectTime(
    BuildContext context, TextEditingController controller) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
  if (picked != null) {
    controller.text = "${picked.hour}:${picked.minute}";
  }
}
