import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Loading indicators
import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart';
import 'package:vv/Caregiver/mainpagecaregiver/patient_list.dart';
import 'package:vv/api/login_api.dart'; // Assuming Dio is set up here
import 'package:vv/utils/storage_manage.dart'; // Secure storage for patient ID
import 'package:vv/widgets/background.dart';

class PatientAllGame extends StatefulWidget {
  @override
  _PatientAllGameState createState() => _PatientAllGameState();
}

class _PatientAllGameState extends State<PatientAllGame> {
  List<Map<String, dynamic>> gameHistories = [];
  bool isLoading = true;
  final SecureStorageManager storageManager = SecureStorageManager();

  @override
  void initState() {
    super.initState();
    _fetchGameData();
  }

  Future<void> _fetchGameData() async {
    String? patientId = await storageManager
        .getPatientId(); // Retrieve patient ID from secure storage
    print("Retrieved Patient ID: $patientId"); // Get the stored patient ID
    try {
      final response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Caregiver/GetGameScoreforPatinet/$patientId');
      List<dynamic> data = response.data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Patient's Game History", style: TextStyle(
          color: Colors.white, // Set text color to white
          fontWeight: FontWeight.bold,
        )),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Set icon color to white
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      mainpagecaregiver()), // Ensure this is the correct class name for your Assign Patient Screen
            );
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // Set background color to blue
      ),
      body: Background(
        SingleChildScrollView: null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: isLoading
                    ? Center(
                        child: SpinKitFadingCircle(
                            color: Colors.white, // Set loading indicator color
                            size: 50.0), // Improved loading indicator
                      )
                    : gameHistories.isEmpty
                        ? Center(
                            child: Text(
                              "No history available.",
                              style: TextStyle(fontSize: 18.0, color: Colors.white), // Set text color to white
                            ),
                          )
                        : ListView.builder(
                            itemCount: gameHistories.length,
                            itemBuilder: (context, index) {
                              final item = gameHistories[index];
                              return Card(
                                elevation: 2.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                shape: RoundedRectangleBorder( // Rounded corners
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ListTile(
                                  leading: Icon(Icons.gamepad, color: Colors.blueAccent),
                                  title: Text('Game: ${item['gameScoreName']}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)), // Set text color to black
                                  subtitle: Text(
                                      'Difficulty: ${item['difficultyGame']}, Score: ${item['patientScore']}, Max Score: ${item['maxScore']}',
                                      style: TextStyle(color: Colors.black)), // Set text color to black
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