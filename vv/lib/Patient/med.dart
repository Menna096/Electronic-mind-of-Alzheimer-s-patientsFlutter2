
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
      Response response = await DioService().dio.get(url); // Assuming you have Dio set up
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
      backgroundColor: const Color(0xFFF2F2F2), // Light gray background

      appBar: AppBar(
        title: const Text('Medicines List'),
        // Change the background color to transparent
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow for a cleaner look
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const mainpatient(), // Navigate to main patient page
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
                            const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                              _buildMedicineDetailRow(
                                  'Dosage:', '${medicine['dosage']} mg'),
                              const SizedBox(height: 8),
                              _buildMedicineDetailRow('Type:',
                                  _formatMedicineType(medicine['medcineType'])),
                              const SizedBox(height: 8),
                              _buildMedicineDetailRow('Repeats:',
                                  ' Every ${medicine['repeater']} hours'),
                              const SizedBox(height: 8),
                              _buildMedicineDetailRow(
                                  'Start:', _formatDate(medicine['startDate'])),
                              const SizedBox(height: 8),
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

class MedicineDetailsPatient extends StatelessWidget {
  final Reminder reminder;

  const MedicineDetailsPatient({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2), // Light gray background
      body: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent, // Make the Scaffold transparent
            appBar: AppBar(
              title: const Text('Medicine Details'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context); // Go back to the previous screen
                },
              ),
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
                        const Icon(Icons.medication,
                            size: 30,
                            color: Color.fromARGB(255, 169, 48, 48)),
                        const SizedBox(width: 10),
                        Text(
                          reminder.Medication_Name,
                          style: const TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'dubai'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Detail Rows with Icons

                    _buildDetailRow(Icons.medication_liquid_outlined,
                        'Dosage:', reminder.Dosage),
                    _buildDetailRow(Icons.medical_services, 'Medicine Type:',
                        _getMedicineType(reminder.medicineType)),
                    _buildDetailRow(Icons.access_time, 'Repeater:',
                        ' Every ${reminder.Repeater} hours'),
                    _buildDetailRow(Icons.calendar_today, 'Start Date:',
                        _formatDate(reminder.startDate)),
                    _buildDetailRow(Icons.calendar_today, 'End Date:',
                        _formatDate(reminder.endDate)),

                    const SizedBox(height: 30),
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
          Icon(icon, size: 24, color: const Color.fromARGB(255, 64, 116, 166)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 25,
                    color: Color.fromARGB(210, 47, 47, 47),
                    fontWeight: FontWeight.w100,
                    fontFamily: 'ProtestRiot'),
              ),
              const SizedBox(height: 20),
              Text(
                value,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper function to format the medicine type
  String _getMedicineType(int type) {
    switch (type) {
      case 0:
        return 'Bottle';
      case 1:
        return 'Pill';
      case 2:
        return 'Syringe';
      case 3:
        return 'Tablet';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}

