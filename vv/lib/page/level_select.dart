import 'package:flutter/material.dart';
import 'package:vv/page/memory_game.dart';

import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/background.dart';
import 'package:vv/widgets/task_widgets/appbarscreens.dart';

class LevelSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        ('Memory Card Game'),
      ),
      body: Background(
        SingleChildScrollView: null,
        child: Center(
          child: Column(
            children: [
              backbutton(),
              Spacer(flex: 1),
              Text(
                'Welcome To Memory Card Game',
                style: TextStyle(fontSize: 22),
              ),
              Text(
                'Please select a level',
                style: TextStyle(fontSize: 22),
              ),
              Spacer(flex: 3),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildLevelButton(context, "Level 1 (6 pairs)", 1),
                  SizedBox(height: 10),
                  buildLevelButton(context, "Level 2 (12 pairs)", 2),
                  SizedBox(height: 10),
                  buildLevelButton(context, "Level 3 (18 pairs)", 3),
                ],
              ),
              Spacer(flex: 5)
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton buildLevelButton(
      BuildContext context, String text, int level) {
    return ElevatedButton(
      onPressed: () => navigateToMemoryCardGame(context, level),
      child: Text(text),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF0386D0),
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(27.0),
        ),
      ),
    );
  }

  void navigateToMemoryCardGame(BuildContext context, int level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryCardGame(level: level),
      ),
    );
  }
}
