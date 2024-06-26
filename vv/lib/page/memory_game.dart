import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/utils/game_time_manage.dart';
import 'package:vv/widgets/animation.dart';
import 'package:vv/widgets/background.dart';

class MemoryCardGame extends StatefulWidget {
  final int level;

  const MemoryCardGame({super.key, required this.level});

  @override
  _MemoryCardGameState createState() => _MemoryCardGameState();
}

class _MemoryCardGameState extends State<MemoryCardGame> {
  final List<String> symbols = [
    '🍎',
    '🍉',
    '🍌',
    '🍒',
    '🍓',
    '🥝',
    '🍍',
    '🍋',
    '🥥',
    '🍇',
    '🍏',
    '🍊',
    '🥭',
    '🍐',
    '🍅',
    '🌽',
    '🥦',
    '🍄'
  ];
  late DateTime startTime;
  late List<String> cards;
  late int timerSeconds;
  late int score;
  late int maxLevel;
  late int level;
  late bool processing;
  late List<int> selectedIndices;
  late List<int> matchedIndices;
  late TimerManager _timerManager;
  late bool symbolsVisible;

  @override
  void initState() {
    super.initState();
    level = widget.level;
    symbolsVisible = true; // Initially set to true to show symbols
    initializeGame();
    _timerManager = TimerManager(
      initialSeconds: 120,
      onTick: _updateTimer,
      onTimerFinish: gameOver,
    );
    // Start the timer after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _timerManager.start();
      _toggleSymbolsVisibility(
          0); // Hide symbols immediately after timer starts
    });
  }

  // Delayed hide action after the specified duration
  void _toggleSymbolsVisibility(int duration) {
    Future.delayed(Duration(seconds: duration), () {
      setState(() {
        symbolsVisible = false; // Hide symbols after specified duration
      });
    });
  }

  @override
  void dispose() {
    _timerManager.stop();
    super.dispose();
  }

  void initializeGame() {
    startTime = DateTime.now();
    final pairsCount = level * 6;
    cards = _generateCards(pairsCount);
    timerSeconds = 120;
    score = 0;
    maxLevel = 3;
    processing = false;
    selectedIndices = [];
    matchedIndices = [];
  }

  List<String> _generateCards(int pairsCount) {
    final temp = List<String>.generate(
        pairsCount, (index) => symbols[index % symbols.length]);
    temp.shuffle();
    return [...temp, ...temp]..shuffle();
  }

  void _updateTimer(int secondsLeft) {
    setState(() {
      timerSeconds = secondsLeft;
    });
  }

  void handleTap(int index) {
    if (!processing &&
        !selectedIndices.contains(index) &&
        !matchedIndices.contains(index)) {
      setState(() {
        selectedIndices.add(index);
      });

      if (selectedIndices.length == 2) {
        setState(() {
          processing = true;
        });

        Timer(const Duration(milliseconds: 50), () {
          if (cards[selectedIndices[0]] == cards[selectedIndices[1]]) {
            setState(() {
              matchedIndices.addAll(selectedIndices);
              selectedIndices = [];
              updateScore(1);
            });
            if (matchedIndices.length == cards.length) {
              gameOver();
            }
          } else {
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                selectedIndices = [];
              });
            });
          }
          setState(() {
            processing = false;
          });
        });
      }
    }
  }

  void updateScore(int delta) {
    setState(() {
      score += delta;
    });
  }

  Future<void> postScoreUsingDio() async {
    // Construct the JSON data
    Map<String, dynamic> jsonData = {
      'patientScore': score,
      'difficultyGame': (level - 1),
    };

    try {
      var response = await DioService().dio.post(
            'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/AddGameScore', // Replace with your actual server URL
            data: jsonData,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
              },
            ),
          );

      if (response.statusCode == 200) {
        // If the server returns an OK response, handle data or notify user
        print("Score posted successfully: ${response.data}");
      } else {
        // Handle errors
        print("Failed to post score: ${response.statusCode}");
      }
    } catch (e) {
      // Error handling if sending the request failed
      print("Error posting score: $e");
    }
  }

  void gameOver() {
    postScoreUsingDio();
    if (matchedIndices.length != cards.length) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Game Over'.tr()),
          content: Text('you_lost_try_again'.tr(args: [score.toString()])),
          actions: <Widget>[
            TextButton(
              child: Text('Restart'.tr()),
              onPressed: () {
                Navigator.of(context).pop();
                restartGame(visibilityDuration: 3);
              },
            ),
          ],
        ),
      );
    } else {
      _timerManager.stop(); // Stop the timer
      showCelebrationAnimation();
    }
  }

  void restartGame({int visibilityDuration = 2}) {
    setState(() {
      score = 0;
      initializeGame();
    });
    _timerManager.reset();
    Future.delayed(const Duration(seconds: 3), () {
      _timerManager.start();
      _toggleSymbolsVisibility(
          0); // Hide symbols immediately after timer starts
    });
    symbolsVisible = true; // Set symbols visible before toggling
  }

  void showCelebrationAnimation() {
    Duration timeTaken = DateTime.now().difference(startTime);
    String timeTakenString =
        '${timeTaken.inMinutes} ${'minutes'.tr()} ${timeTaken.inSeconds.remainder(60)} ${'seconds'.tr()}';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const VictoryAnimationScreen(),
            Text(
              'congratulations_message'.tr(namedArgs: {
                'score': score.toString(),
                'timeTaken': timeTakenString,
              }),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                restartGame(visibilityDuration: 1);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF0386D0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27.0),
                ),
              ),
              child: Text('Restart'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(int index) {
    final isMatched = matchedIndices.contains(index);
    final isSelected = selectedIndices.contains(index);
    final symbol = cards[index];

    return GestureDetector(
      onTap: () => handleTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected || isMatched ? Colors.grey : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            symbolsVisible || isSelected || isMatched
                ? symbol
                : '', // Toggle visibility
            style: const TextStyle(fontSize: 40.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Card Game'.tr()),
      ),
      body: Background(
        SingleChildScrollView: null,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('score_label'.tr(args: [score.toString()]),
                    style: const TextStyle(fontSize: 20)),
                Text(
                  'time_label'.tr(args: [timerSeconds.toString()]),
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: level == maxLevel ? 6 : 4,
                ),
                itemCount: cards.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: buildCard(index),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                restartGame(visibilityDuration: 3);
              },
              // ignore: sort_child_properties_last
              child: Text('Restart'.tr()),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF0386D0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27.0),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
