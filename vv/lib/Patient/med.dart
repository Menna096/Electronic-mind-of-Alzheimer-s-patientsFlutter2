import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';

class Pagee extends StatefulWidget {
  @override
  _PageeState createState() => _PageeState();
}

class _PageeState extends State<Pagee> {
  HubConnection? medicineReminderHubConnection;
  List<Medicine> medicines = [];
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    connectToHub();
    fetchInitialMedicines();
  }

  @override
  void dispose() {
    medicineReminderHubConnection?.stop();
    super.dispose();
  }

  Future<void> connectToHub() async {
    medicineReminderHubConnection = HubConnectionBuilder()
        .withUrl(
            'https://electronicmindofalzheimerpatients.azurewebsites.net/hubs/medicineReminder')
        .build();

    // Listen for updates
    medicineReminderHubConnection!.on('ReceiveMedicineReminder', (arguments) {
      final action = arguments?[0] as String?;
      final medicationData = arguments?[1] as Map<String, dynamic>?;

      if (action != null && medicationData != null) {
        if (action == 'add') {
          final medicine = Medicine.fromJson(medicationData);
          setState(() {
            medicines.add(medicine);
          });
        } else if (action == 'delete') {
          final medicineId = medicationData['reminderId']; // Assuming 'reminderId' is the ID field
          setState(() {
            medicines.removeWhere((medicine) => medicine.reminderId == medicineId);
          });
        }
      }
    });

    await medicineReminderHubConnection!.start();
  }

  Future<void> fetchInitialMedicines() async {
    final url =
        'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetAllMedicines';
    final headers = {
      'accept': '*/*',
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJlZDE0NTUwYi1hMTU0LTQ0MTQtOTcxYy1kZDI5OGZhNjY4MjAiLCJlbWFpbCI6Im1lbm5hcmFnYWIyMjBAZ21haWwuY29tIiwiRnVsbE5hbWUiOiJtZW5uYSIsIlBob25lTnVtYmVyIjoiMTExMTExMSIsInVpZCI6IjEyMjBhYzFjLWM4MDAtNDE5NC05MzNhLTY3NTg2MDczZTRkNCIsIlVzZXJBdmF0YXIiOiJodHRwczovL2VsZWN0cm9uaWNtaW5kb2ZhbHpoZWltZXJwYXRpZW50cy5henVyZXdlYnNpdGVzLm5ldC9Vc2VyIEF2YXRhci8xMjIwYWMxYy1jODAwLTQxOTQtOTMzYS02NzU4NjA3M2U0ZDRfODFjMzY3NjctZmY0Ni00MjY3LWIzYmUtYWY0YTdiMjllY2MxLmpwZWciLCJNYWluTGF0aXR1ZGUiOiIyOS45Nzc5NzE1ODMzMzMzMzYiLCJNYWluTG9uZ2l0dWRlIjoiMzIuNTI4ODg3NSIsInJvbGVzIjoiUGF0aWVudCIsIk1heERpc3RhbmNlIjoiMTUwIiwiZXhwIjoxNzI1MzE0Mzg5LCJpc3MiOiJBcnTOZkNvZGluZyIsImF1ZCI6IkFsemhlaW1hckFwcCJ9.aIo5lVCOWLLmSUHWk77OZdyO8_8g-9VtG6iLumhHr7w',
    };

    try {
      final response = await _dio.get(url, options: Options(headers: headers));

      if (response.statusCode == 200) {
        final jsonData = response.data as List<dynamic>;
        setState(() {
          medicines =
              jsonData.map((medicine) => Medicine.fromJson(medicine)).toList();
        });
      } else {
        print('Failed to fetch medicines: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching medicines: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Reminder'),
      ),
      body: ListView.builder(
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          final medicine = medicines[index];
          return ListTile(
            title: Text(medicine.medication_Name), // Assuming 'medication_Name' is the name field
            subtitle: Text('Dosage: ${medicine.dosage}'),
          );
        },
      ),
    );
  }
}

class Medicine {
  final String reminderId;
  final String medication_Name;
  final String dosage;

  Medicine({
    required this.reminderId,
    required this.medication_Name,
    required this.dosage,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      reminderId: json['reminderId'],
      medication_Name: json['medication_Name'],
      dosage: json['dosage'],
    );
  }
}