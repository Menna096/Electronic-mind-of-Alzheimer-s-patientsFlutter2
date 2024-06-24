import 'package:flutter/material.dart';

class Backgroundd extends StatelessWidget {
  final Widget child;

  const Backgroundd({super.key, required this.child, required SingleChildScrollView });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 81, 116, 190),
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffFFFFFF),
              Color.fromARGB(255, 81, 116, 190),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
