import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/widgets/background.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;

  AppointmentDetailScreen({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Appointment ID: ${appointment.id}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Date: ${appointment.date}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Location: ${appointment.location}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Notes: ${appointment.notes}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Family Name: ${appointment.familyName}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Can Be Deleted: ${appointment.canBeDeleted}',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

class AppointmentScreenPatient extends StatefulWidget {
  @override
  _AppointmentScreenPatientState createState() =>
      _AppointmentScreenPatientState();
}

class _AppointmentScreenPatientState extends State<AppointmentScreenPatient> {
  List<dynamic> appointments = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    String url =
        'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetAllAppointments';

    try {
      Response response = await DioService().dio.get(url);
      setState(() {
        appointments = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching appointments: $e';
        isLoading = false;
      });
    }
  }

  void showAppointmentDetails(Map<String, dynamic> appointment) {
    // Parse the date and time
    DateTime dateTime = DateTime.parse(appointment['date']);
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    String formattedTime = DateFormat('hh:mm a').format(dateTime);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          title: Text(
            appointment['notes'],
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: $formattedDate',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 5),
              Text(
                'Time: $formattedTime',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 5),
              Text(
                'Location: ${appointment['location']}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 5),
              Text(
                'Created by: ${appointment['familyNameWhoCreatedAppointemnt']}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Appointments')),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Background(
                  SingleChildScrollView: null,
                  child: ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      var appointment = appointments[index];
                      return GestureDetector(
                        onTap: () => showAppointmentDetails(appointment),
                        child: Card(
                          color: Color.fromARGB(72, 255, 255, 255),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.calendar_today_rounded),
                            title: Text(
                              appointment['notes'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
