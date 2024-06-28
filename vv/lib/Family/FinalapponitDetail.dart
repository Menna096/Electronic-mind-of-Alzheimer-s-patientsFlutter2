import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:vv/Family/appoint_list.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDetailsScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const AppointListScreen()),
            );
          },
        ),
        title: Text(
          "Appointment Details".tr(),
          style: const TextStyle(
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
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30.0),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location:'.tr(),
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF616161),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      appointment['location'] ?? 'No location provided',
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Color(0xFF616161),
                      ),
                    ),
                    const Divider(),
                    Text(
                      'Notes:'.tr(),
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF616161),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      appointment['notes'] ?? 'No notes provided',
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Color(0xFF616161),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
