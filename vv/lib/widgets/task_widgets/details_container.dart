import 'package:flutter/material.dart';

class TaskDetailsContainer extends StatelessWidget {
  final Widget child;

  const TaskDetailsContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
