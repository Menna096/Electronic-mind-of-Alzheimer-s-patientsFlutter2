import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class VictoryAnimationScreen extends StatefulWidget {
  const VictoryAnimationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VictoryAnimationScreenState createState() => _VictoryAnimationScreenState();
}

class _VictoryAnimationScreenState extends State<VictoryAnimationScreen> {
  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  void startAnimation() {
    Timer(const Duration(seconds: 1), () {
      setState(() {
        _emoji = '🎉';
      });
    });
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _emoji = '🏆';
      });
    });
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _emoji = '🌟';
      });
    });
    Timer(const Duration(seconds: 4), () {
      setState(() {
        _emoji = '🎊';
      });
    });
    Timer(const Duration(seconds: 5), () {
      setState(() {
        _emoji = '✨';
      });
    });
  }

  String _emoji = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _emoji,
              key: Key(_emoji), // Ensure unique key when the emoji changes
              style: const TextStyle(fontSize: 60),
            ),
          ),
        ),
         Text('congratulations!'.tr())
      ],
    );
  }
}
