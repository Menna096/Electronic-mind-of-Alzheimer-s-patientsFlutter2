import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vv/Family/FinalapponitDetail.dart';
import 'package:vv/Family/appoint_details.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/task_widgets/dayselect.dart';
import 'package:vv/widgets/task_widgets/yearmonth.dart';
import '../../models/appoint.dart';
import 'addApoint.dart';

class AppointListScreen extends StatefulWidget {
  @override
  _AppointListScreenState createState() => _AppointListScreenState();
}

class _AppointListScreenState extends State<AppointListScreen> {
  List<dynamic> appointments = [];
  Appointment? selectedAppoint;

//
  Color pickedColor = const Color(0xFF0386D0);
  // void updateAppoint(Appointment oldAppoint, Appointment newAppoint) {
  //   setState(() {
  //     final index = Appoints.indexOf(oldAppoint);
  //     Appoints[index] = newAppoint;
  //   });
  // }
  @override
  void initState() {
    super.initState();

    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    try {
      final response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/GetPatientAppointments');
      setState(() {
        appointments = response.data;
      });
    } catch (e) {
      print('Error fetching appointments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: AlignmentDirectional.bottomCenter,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xffFFFFFF),
            Color(0xff3B5998),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              elevation: 2, // Adjust the elevation as needed
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(39.0),
                bottomRight: const Radius.circular(39.0),
              ),
              color: const Color.fromRGBO(255, 255, 255, 0.708),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(39.0),
                  bottomRight: Radius.circular(39.0),
                ),
                child: Container(
                  decoration: const BoxDecoration(),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      const Center(
                        child: Text(
                          'Appointments',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                      const backbutton(),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 40,
                          ),
                          const CurrentMonthYearWidget(),
                          const SizedBox(
                            width: 40,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AddAppointmentScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // Set circular border radius
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 30),
                                // Increase vertical padding
                                elevation: 4,
                                backgroundColor:
                                    pickedColor, // Add some elevation
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    'Add ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text('Appointment',
                                      style: TextStyle(color: Colors.white))
                                ],
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: DaySelector(),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                'Appointments',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  final bool canDelete = appointment['canDeleted'] ??
                      false; // Default to false if not present

                  return ListTile(
                    leading: Icon(Icons.calendar_today_rounded),
                    title: Text(appointment['location']),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd HH:mm')
                          .format(DateTime.parse(appointment['date'])),
                    ),
                    trailing: canDelete
                        ? IconButton(
                            onPressed: () {
                              _deleteAppointment(appointment['appointmentId']);
                            },
                            icon: Icon(Icons.delete),
                          )
                        : null, // Null if can't delete
                    onTap: () {
                      _navigateToAppointmentDetails(appointment);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAppointmentDetails(Map<String, dynamic> appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AppointmentDetailsScreen(appointment: appointment),
      ),
    );
  }

  void _deleteAppointment(String appointmentId) async {
    try {
      // Make delete request to the endpoint
      await DioService().dio.delete(
            'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/DeleteAppointment/$appointmentId',
          );
      // If successful, refresh the list of appointments
      await fetchAppointments();
      // Optionally, show a success message or perform any other actions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment deleted successfully')),
      );
    } catch (e) {
      // Handle errors, e.g., show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete appointment: $e')),
      );
      print('Failed to delete appointment: $e');
    }
  }
}
