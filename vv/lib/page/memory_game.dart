import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vv/utils/game_time_manage.dart';
import 'package:vv/widgets/animation.dart';
import 'package:vv/widgets/background.dart';

class MemoryCardGame extends StatefulWidget {
  final int level;

  const MemoryCardGame({Key? key, required this.level}) : super(key: key);

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
      initialSeconds: 30,
      onTick: _updateTimer,
      onTimerFinish: gameOver,
    );
    _timerManager.start();
    _toggleSymbolsVisibility(3); // Call to start the visibility toggle
  }

  // Delayed hide action after 2 seconds
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
    timerSeconds = 30; // Set timer to 30 seconds
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

        Timer(Duration(milliseconds: 50), () {
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
            Future.delayed(Duration(seconds: 1), () {
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

  void gameOver() {
    if (matchedIndices.length != cards.length) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Game Over'),
          content: Text('You lost. Try again! Your score: $score'),
          actions: <Widget>[
            TextButton(
              child: Text('Restart'),
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
    _timerManager.start();
    symbolsVisible = true; // Set symbols visible before toggling
    _toggleSymbolsVisibility(
        visibilityDuration); // Call to start the visibility toggle with custom duration
  }

  void showCelebrationAnimation() {
    Duration timeTaken = DateTime.now().difference(startTime);
    String timeTakenString =
        '${timeTaken.inMinutes} minutes ${timeTaken.inSeconds.remainder(30)} seconds';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VictoryAnimationScreen(),
            Text(
                'Congratulations! Your Score: $score\nTime Taken: $timeTakenString'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                restartGame(visibilityDuration: 1);
              },
              child: Text('Restart'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF0386D0),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27.0),
                ),
              ),
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
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected || isMatched ? Colors.grey : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            symbolsVisible || isSelected || isMatched
                ? symbol
                : '', // Toggle visibility
            style: TextStyle(fontSize: 40.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Card Game'),
      ),
      body: Background(
        SingleChildScrollView: null,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $score', style: TextStyle(fontSize: 20)),
                Text('Time: $timerSeconds', style: TextStyle(fontSize: 20)),
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
              child: Text('Restart'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF0386D0),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27.0),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
