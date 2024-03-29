import 'dart:async';
import 'package:flutter/material.dart';

class VictoryAnimationScreen extends StatefulWidget {
  @override
  _VictoryAnimationScreenState createState() => _VictoryAnimationScreenState();
}

class _VictoryAnimationScreenState extends State<VictoryAnimationScreen> {
  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  void startAnimation() {
    Timer(Duration(seconds: 1), () {
      setState(() {
        _emoji = '🎉';
      });
    });
    Timer(Duration(seconds: 2), () {
      setState(() {
        _emoji = '🏆';
      });
    });
    Timer(Duration(seconds: 3), () {
      setState(() {
        _emoji = '🌟';
      });
    });
    Timer(Duration(seconds: 4), () {
      setState(() {
        _emoji = '🎊';
      });
    });
    Timer(Duration(seconds: 5), () {
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
            duration: Duration(milliseconds: 500),
            child: Text(
              _emoji,
              key: Key(_emoji), // Ensure unique key when the emoji changes
              style: TextStyle(fontSize: 60),
            ),
          ),
        ),
        Text('congratulations!')
      ],
    );
  }
}
