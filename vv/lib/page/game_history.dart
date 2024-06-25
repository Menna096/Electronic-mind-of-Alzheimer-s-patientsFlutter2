import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:vv/api/login_api.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

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

  String formatDate(String dateString) {
    final DateTime date = DateTime.parse(dateString);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String formatDifficulty(int difficulty) {
    switch (difficulty) {
      case 0:
        return 'Easy'.tr();
      case 1:
        return 'Medium'.tr();
      case 2:
        return 'Hard'.tr();
      default:
        return 'Unknown'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:  Text(
          "Game History".tr(),
          style: TextStyle(
            fontFamily: 'LilitaOne',
            fontSize: 23,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A95E9), Color(0xFF38A4C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(10.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(66, 55, 134, 190),
                offset: Offset(0, 10),
                blurRadius: 10.0,
              ),
            ],
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50.0),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffECEFF5),
              Color(0xff3B5998),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
               Text(
                "Game History".tr(),
                style: TextStyle(
                  fontSize: 23,
                  fontFamily: 'Acme',
                  color: Color(0xFF6A95E9),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: SpinKitFadingCircle(
                          color: Colors.white,
                          size: 50.0,
                        ),
                      )
                    : gameHistories.isEmpty
                        ?  Center(
                            child: Text(
                              "No history available.".tr(),
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: gameHistories.length,
                            itemBuilder: (context, index) {
                              final item = gameHistories[index];
                              return Card(
                                elevation: 5.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(Icons.sports_esports,
                                              color: Color(0xFF6A95E9),
                                              size: 32),
                                          Text(
                                              tr('gameDate', args: [formatDate(item['gameDate'])]),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 67, 115, 219))),
                                        ],
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        'difficulty'.tr(args: [item['difficultyGame']]),
                                        style: const TextStyle(
                                            fontFamily: 'dubai',
                                            fontSize: 15,
                                            color: Color.fromARGB(
                                                255, 100, 100, 100)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'score'.tr(args: [item['patientScore'].toString()]),
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 143, 172, 212)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
