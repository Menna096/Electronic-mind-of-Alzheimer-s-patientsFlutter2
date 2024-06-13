import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/page/game_history.dart';
import 'package:vv/page/memory_game.dart';
import 'package:vv/widgets/background.dart';

class LevelSelectionScreen extends StatefulWidget {
  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  int? recommendedLevel;
  int? currentScore;
  int? maxScore;
  double _position = 50.0; // Added missing variable

  @override
  void initState() {
    super.initState();
    fetchRecommendedLevel();
    fetchCurrentAndMaxScore();
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

  Future<void> fetchCurrentAndMaxScore() async {
    try {
      var response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetCurrentAndMaxScore');
      if (response.statusCode == 200) {
        setState(() {
          currentScore = response.data['score']['currentScore'];
          maxScore = response.data['score']['maxScore'];
        });
      }
    } catch (e) {
      print('Failed to fetch current and max scores: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xff3B5998) ,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white,Color(0xff3B5998)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(seconds: 1),
            top: _position,
            left: -100,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(seconds: 1),
            bottom: -_position,
            right: -100,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 45),
                  Text(
                    'Memory Card Game',
                    style: TextStyle(
                      fontSize: 35,
                      fontFamily: 'LilitaOne',
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [Colors.blue[400]!, Colors.indigo[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(
                          Rect.fromLTWH(0, 0, 400, 10),
                        ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackButton(),
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.history,
                          size: 30,
                          color: const Color.fromARGB(255, 48, 48, 48),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (currentScore != null && maxScore != null)
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 233, 247, 255),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(136, 69, 121, 173)
                                .withOpacity(0.3),
                            spreadRadius: 3,
                            blurRadius: 4,
                            offset: Offset(-1, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(17),
                      child: Column(
                        children: [
                          Text(
                            'Current Score: $currentScore',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 50, 58, 145),
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Max Score: $maxScore',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 50, 58, 145),
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 50),
                  Text(
                    'Select a Level',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'dubai',
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      buildLevelButton(
                        context,
                        recommendedLevel != null
                            ? recommendedLevel == 0
                                ? 'Recommended Level: Easy'
                                : recommendedLevel == 1
                                    ? 'Recommended Level: Medium'
                                    : recommendedLevel == 2
                                        ? 'Recommended Level: Hard'
                                        : 'Recommended Level: $recommendedLevel'
                            : 'Loading...',
                        recommendedLevel != null ? recommendedLevel! + 1 : 0,
                      ),
                      SizedBox(height: 16),
                      buildLevelButton(context, "Easy (6 pairs)", 1),
                      SizedBox(height: 16),
                      buildLevelButton(context, "Medium (12 pairs)", 2),
                      SizedBox(height: 16),
                      buildLevelButton(context, "Hard (18 pairs)", 3),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildLevelButton(BuildContext context, String text, int level) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      gradient: LinearGradient(
        colors: [Colors.blue[400]!, Colors.indigo[400]!],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.indigo.withOpacity(0.2),
          blurRadius: 10,
          spreadRadius: 3,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed:
          level > 0 ? () => navigateToMemoryCardGame(context, level) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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
