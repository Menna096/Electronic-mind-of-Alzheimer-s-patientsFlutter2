import 'package:flutter/material.dart';

class TimeSelectionRow extends StatelessWidget {
  final List<Widget> children;

  const TimeSelectionRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children,
    );
  }
}
