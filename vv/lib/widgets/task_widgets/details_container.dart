import 'package:flutter/material.dart';

class TaskDetailsContainer extends StatelessWidget {
  final Widget child;

  const TaskDetailsContainer({super.key, required this.child, required BorderRadius borderRadius, required List<BoxShadow> shadow});

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
     
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
