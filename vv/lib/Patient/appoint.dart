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

class _AppointmentScreenPatientState extends State<AppointmentScreenPatient>
    with SingleTickerProviderStateMixin {
  List<dynamic> appointments = [];
  bool isLoading = true;
  String errorMessage = '';
  late AnimationController _controller;
  double _position = -200;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchAppointments();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    )..addListener(() {
        setState(() {
          _position += 1;
          if (_position > 300) _position = -200;
        });
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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
              color: Color(0xff3B5998),
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
                  color: Color(0xff3B5998),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _calculateOpacity(int index) {
    double itemPosition = index * 100.0; // Approximate height of each item
    double scrollOffset = _scrollController.offset;
    if (scrollOffset > itemPosition) {
      return 0.0;
    } else {
      return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background with animated circular shapes
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff3B5998), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(seconds: 1),
            top: _position,
            left: -100,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(seconds: 1),
            bottom: -_position,
            right: -100,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          // Main content
          isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
                  ? Center(child: Text(errorMessage))
                  : NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        setState(() {});
                        return false;
                      },
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverAppBar(
                            title: Text('Appointments'),
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            pinned: true,
                            leading: IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => mainpatient(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.all(16.0),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  var appointment = appointments[index];
                                  return Opacity(
                                    opacity: _calculateOpacity(index),
                                    child: GestureDetector(
                                      onTap: () =>
                                          showAppointmentDetails(appointment),
                                      child: Card(
                                        color: Colors.white.withOpacity(0.8),
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8),
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                              Icons.calendar_today_rounded,
                                              color: Color(0xff3B5998)),
                                          title: Text(
                                            appointment['notes'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          trailing: Icon(
                                              Icons.arrow_forward_ios,
                                              color: Color(0xff3B5998)),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                childCount: appointments.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        ],
      ),
    );
  }
}
