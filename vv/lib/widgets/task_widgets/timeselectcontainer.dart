import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TimeSelectionContainer extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final TimeOfDay? time;

  const TimeSelectionContainer({
    super.key,
    required this.label,
    required this.onPressed,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: const Color(0x200386D0),
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
                style: const TextStyle(
                  color: Color.fromARGB(255, 2, 93, 184),
                  fontSize: 20.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                time != null ? time!.format(context) : 'Select Time'.tr(),
                style: const TextStyle(
                  color: Color.fromARGB(255, 113, 113, 113),
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
