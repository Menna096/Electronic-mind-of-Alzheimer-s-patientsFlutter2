import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:signalr_core/signalr_core.dart';
// import 'package:vv/api/login_api.dart';
// import 'package:vv/utils/token_manage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class Reminder {
  String MedicationId;
  String Medication_Name;
  String Dosage;
  int medicineType;
  int Repeater;
  DateTime startDate;
  DateTime endDate;

  Reminder({
    required this.MedicationId,
    required this.Medication_Name,
    required this.Dosage,
    required this.medicineType,
    required this.Repeater,
    required this.startDate,
    required this.endDate,
  });

  // Factory method to create a Reminder object from JSON
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      MedicationId: json['MedicationId'],
      Medication_Name: json['Medication_Name'],
      Dosage: json['Dosage'],
      medicineType: json['MedcineType'],
      Repeater: json['Repeater'],
      startDate: DateTime.parse(json['StartDate']),
      endDate: DateTime.parse(json['EndDate']),
    );
  }
}

class MedicinesPage extends StatefulWidget {
  @override
  _MedicinesPageState createState() => _MedicinesPageState();
}

class _MedicinesPageState extends State<MedicinesPage> {
  List<dynamic> medicines = [];
  bool isLoading = true;
  String errorMessage = '';
  List<Reminder> reminders = [];
  late HubConnection medicineHubConnection;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    fetchMedicines();
    // initializeConnectionmedicine();
    // initializeNotificationsMedicine();
  }

  Future<void> fetchMedicines() async {
    String url =
        'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetAllMedicines';

    try {
      Response response = await Dio().get(url); // Assuming you have Dio set up
      setState(() {
        medicines = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching medicines: $e';
        isLoading = false;
      });
    }
  }

  String _formatMedicineType(int medicineType) {
    switch (medicineType) {
      case 1:
        return 'Pill';
      case 2:
        return 'Syrup';
      case 3:
        return 'Injection';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a custom background color
      backgroundColor: Color(0xFFF2F2F2), // Light gray background

      appBar: AppBar(
        title: Text('Medicines List'),
        // Change the background color to transparent
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow for a cleaner look
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    var medicine = medicines[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MedicineDetailsPatient(
                              reminder: Reminder(
                                MedicationId:
                                    medicine['medicationId'].toString(),
                                Medication_Name: medicine['medication_Name'],
                                Dosage: medicine['dosage'],
                                medicineType: medicine['medcineType'],
                                Repeater: medicine['repeater'],
                                startDate:
                                    DateTime.parse(medicine['startDate']),
                                endDate: DateTime.parse(medicine['endDate']),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${medicine['medication_Name']}',
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontFamily: 'ConcertOne',
                                        color: Color.fromARGB(255, 27, 94, 138),
                                      ),
                                    ),
                                  ),
                                  // Display image based on medicineType
                                  _buildMedicineTypeIcon(
                                      medicine['medcineType']),
                                ],
                              ),
                              SizedBox(height: 10),
                              _buildMedicineDetailRow(
                                  'Dosage:', '${medicine['dosage']} mg'),
                              SizedBox(height: 8),
                              _buildMedicineDetailRow('Type:',
                                  _formatMedicineType(medicine['medcineType'])),
                              SizedBox(height: 8),
                              _buildMedicineDetailRow('Repeats:',
                                  ' Every ${medicine['repeater']} hours'),
                              SizedBox(height: 8),
                              _buildMedicineDetailRow(
                                  'Start:', _formatDate(medicine['startDate'])),
                              SizedBox(height: 8),
                              _buildMedicineDetailRow(
                                  'End:', _formatDate(medicine['endDate'])),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // Helper function to build medicine type icon
  Widget _buildMedicineTypeIcon(int medicineType) {
    switch (medicineType) {
      case 1:
        return Image.asset(
          'lib/page/task_screens/assets/icons/pills.gif', // Update with correct path
          height: 60,
          width: 60,
        );
      case 0:
        return Image.asset(
          'lib/page/task_screens/assets/icons/liquid.gif', // Update with correct path
          height: 60,
          width: 60,
        );
      case 2:
        return Image.asset(
          'lib/page/task_screens/assets/icons/syringe.gif', // Update with correct path
          height: 60,
          width: 60,
        );
      case 3:
        return Image.asset(
          'lib/page/task_screens/assets/icons/tablet.gif', // Update with correct path
          height: 60,
          width: 60,
        );
      default:
        return Icon(Icons.error, size: 60);
    }
  }

  // Helper function to build medicine detail rows
  Widget _buildMedicineDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label ',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(value),
      ],
    );
  }

  String _formatDate(String dateString) {
    DateTime parsedDate = DateTime.parse(dateString);
    return DateFormat('MMM d, yyyy').format(parsedDate);
  }
}

class MedicineDetailsPatient extends StatelessWidget {
  final Reminder reminder;

  MedicineDetailsPatient({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2), // Light gray background
      body: Stack(
        children: [
          Container(
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
          ),
          Scaffold(
            backgroundColor: Colors.transparent, // Make the Scaffold transparent
            appBar: AppBar(
              title: Text('Medicine Details'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Medication Name with Icon
                    Row(
                      children: [
                        Icon(Icons.medication,
                            size: 30,
                            color: Color.fromARGB(255, 169, 48, 48)),
                        SizedBox(width: 10),
                        Text(
                          reminder.Medication_Name,
                          style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'dubai'),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),

                    // Detail Rows with Icons

                    _buildDetailRow(Icons.medication_liquid_outlined,
                        'Dosage:', reminder.Dosage),
                    _buildDetailRow(Icons.medical_services, 'Medicine Type:',
                        reminder.medicineType.toString()),
                    _buildDetailRow(Icons.access_time, 'Repeater:',
                        ' Every ${reminder.Repeater} hours'),
                    _buildDetailRow(Icons.calendar_today, 'Start Date:',
                        _formatDate(reminder.startDate)),
                    _buildDetailRow(Icons.calendar_today, 'End Date:',
                        _formatDate(reminder.endDate)),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build detail rows with icons
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Color.fromARGB(255, 64, 116, 166)),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                    fontSize: 25,
                    color: Color.fromARGB(210, 47, 47, 47),
                    fontWeight: FontWeight.w100,
                    fontFamily: 'ProtestRiot'),
              ),
              SizedBox(height: 20),
              Text(
                value,
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}