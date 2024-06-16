import 'package:flutter/material.dart';

class Backgroundd extends StatelessWidget {
  final Widget child;

  const Backgroundd({Key? key, required this.child, required SingleChildScrollView }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 81, 116, 190),
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
