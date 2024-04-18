import 'package:flutter/material.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/page/game_history.dart';
import 'package:vv/page/memory_game.dart';

import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/background.dart';

class LevelSelectionScreen extends StatefulWidget {
  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  int? recommendedLevel;

  @override
  void initState() {
    super.initState();
    fetchRecommendedLevel();
  }

  Future<void> fetchRecommendedLevel() async {
    try {
      var response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetAllGameScores');
      if (response.statusCode == 200) {
        setState(() {
          recommendedLevel = response.data['recomendationDifficulty'];
        });
      }
    } catch (e) {
      print('Failed to fetch recommended level: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: buildAppBar('Memory Card Game'),
      body: Background(
        SingleChildScrollView: null,
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 25,
              ),
              Text(
                'Memory Card Game',
                style: TextStyle(fontSize: 35),
              ),
              Row(
                children: [
                  backbutton(),
                  Spacer(
                    flex: 1,
                  ),
                  Column(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HistoryScreen()),
                            );
                          },
                          icon: Icon(
                            Icons.history,
                            size: 40,
                            color: Colors.grey,
                          )),
                    ],
                  )
                ],
              ),
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
                  ElevatedButton(
                    onPressed: recommendedLevel != null
                        ? () => navigateToMemoryCardGame(
                            context, recommendedLevel! + 1)
                        : null,
                    child: Text(recommendedLevel == 0
                            ? 'Recommended Level: Easy'
                            : recommendedLevel == 1
                                ? 'Recommended Level: Medium'
                                : recommendedLevel == 2
                                    ? 'Recommended Level: Hard'
                                    : 'Recommended Level: $recommendedLevel' // Fallback for other values
                        ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF0386D0),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  buildLevelButton(context, "Easy (6 pairs)", 1),
                  SizedBox(height: 10),
                  buildLevelButton(context, "Medium (12 pairs)", 2),
                  SizedBox(height: 10),
                  buildLevelButton(context, "Hard (18 pairs)", 3),
                  SizedBox(height: 20),
                ],
              ),
              Spacer(flex: 5)
            ],
          ),
        ),
      ),
    );
  }
}

ElevatedButton buildLevelButton(BuildContext context, String text, int level) {
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