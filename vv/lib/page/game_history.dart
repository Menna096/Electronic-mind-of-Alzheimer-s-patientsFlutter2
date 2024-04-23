import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // A collection of loading indicators
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/widgets/background.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> gameHistories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGameData();
  }

  Future<void> _fetchGameData() async {
    var dio = Dio();
    try {
      final response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetAllGameScores');
      List<dynamic> data = response.data['gameScore'];
      setState(() {
        gameHistories = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        print('Failed to load data: $e');
      });
    }
  }

  String getDifficultyLabel(int difficulty) {
    switch (difficulty) {
      case 0:
        return 'Easy';
      case 1:
        return 'Medium';
      case 2:
        return 'Hard';
      default:
        return 'Unknown'; // Optional: default case for unknown difficulty
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game History"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Background(
        SingleChildScrollView: null,
        child: Center(
          child: isLoading
              ? const SpinKitFadingCircle(
                  color: Colors.blueAccent,
                  size: 50.0) // Improved loading indicator
              : gameHistories.isEmpty
                  ? const Text(
                      "No history available.",
                      style: TextStyle(fontSize: 18.0, color: Colors.black54),
                    )
                  : ListView.builder(
                      itemCount: gameHistories.length,
                      itemBuilder: (context, index) {
                        final item = gameHistories[index];
                        return Card(
                          elevation: 2.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 10),
                          child: ListTile(
                            leading: const Icon(Icons.gamepad,
                                color: Colors.blueAccent),
                            title: const Text('Game Score',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              'Difficulty: ${getDifficultyLabel(item['difficultyGame'])}, Score: ${item['patientScore']},\nDate: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(item['gameDate']))},',
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
