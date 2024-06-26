import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:signalr_core/signalr_core.dart';
// import 'package:vv/api/login_api.dart';
// import 'package:vv/utils/token_manage.dart';
import 'package:intl/intl.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:vv/api/login_api.dart';

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
  const MedicinesPage({super.key});

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
      Response response =
          await DioService().dio.get(url); // Assuming you have Dio set up
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
        return 'Pill'.tr();
      case 2:
        return 'Syrup'.tr();
      case 3:
        return 'Injection'.tr();
      default:
        return 'Unknown'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a custom background color
      backgroundColor: const Color(0xFFF2F2F2), // Light gray background

      appBar: AppBar(
        title: Text('Medicines List'.tr()),
        // Change the background color to transparent
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow for a cleaner look
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const mainpatient(), // Navigate to main patient page
              ),
            );
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    var medicine = medicines[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${medicine['medication_Name']}',
                                    style: const TextStyle(
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
                            const SizedBox(height: 10),
                            _buildMedicineDetailRow('dosage_label'.tr(),
                                '${medicine['dosage']} mg'),
                            const SizedBox(height: 8),
                            _buildMedicineDetailRow('type_label'.tr(),
                                _formatMedicineType(medicine['medcineType'])),
                            const SizedBox(height: 8),
                            _buildMedicineDetailRow(
                                'repeats_label'.tr(),
                                'repeat_time'.tr(
                                    args: [medicine['repeater'].toString()])),
                            const SizedBox(height: 8),
                            _buildMedicineDetailRow('start_label'.tr(),
                                _formatDate(medicine['startDate'])),
                            const SizedBox(height: 8),
                            _buildMedicineDetailRow('end_label'.tr(),
                                _formatDate(medicine['endDate'])),
                          ],
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
        return const Icon(Icons.error, size: 60);
    }
  }

  // Helper function to build medicine detail rows
  Widget _buildMedicineDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label ',
          style: const TextStyle(fontWeight: FontWeight.w500),
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
