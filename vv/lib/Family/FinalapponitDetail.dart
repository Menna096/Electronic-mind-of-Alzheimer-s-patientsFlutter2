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
              MaterialPageRoute(builder: (context) => const AppointListScreen()),
            );
          },
        ),
        title: const Text(
          "Appointment Details",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 4,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 285, horizontal: 101),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10.0),
                    Text(
                      'Location: ${appointment['location']}',
                      style: const TextStyle(
                          fontSize: 26.0,
                          color: Color.fromARGB(255, 83, 137, 184),
                          fontFamily: 'LilitaOne'),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      'Notes: ${appointment['notes']}',
                      style: const TextStyle(
                          fontSize: 26.0,
                          color: Color.fromARGB(255, 83, 137, 184),
                          fontFamily: 'LilitaOne'),
                    ),
                    // SizedBox(height: 10.0),
                    // Text(
                    //   'Created by: ${appointment['familyNameWhoCreatedAppointemnt']}',
                    //   style: TextStyle(
                    //     fontSize: 26.0,
                    //       color: Color.fromARGB(255, 83, 137, 184),
                    //       fontFamily: 'LilitaOne'
                    //   ),
                    // ),
                    // SizedBox(height: 10.0),
                    // Text(
                    //   'Can be deleted: ${appointment['canDeleted']}',
                    //   style: TextStyle(
                    //     fontSize: 18.0,
                    //     color: Colors.indigo[600],
                    //   ),
                    // ),
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
