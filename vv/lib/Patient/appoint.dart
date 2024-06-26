import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:vv/api/login_api.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Appointment ID: ${appointment.id}'.tr(),
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Date: ${appointment.date}'.tr(),
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Location: ${appointment.location}'.tr(),
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Notes: ${appointment.notes}'.tr(),
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Family Name: ${appointment.familyName}'.tr(),
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Can Be Deleted: ${appointment.canBeDeleted}'.tr(),
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

class AppointmentScreenPatient extends StatefulWidget {
  const AppointmentScreenPatient({super.key});

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
      duration: const Duration(seconds: 5),
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
        errorMessage = 'Error fetching appointments'.tr();
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
            style: const TextStyle(
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
                'date_label'.tr(args: [formattedDate]),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                'time_label'.tr(args: [formattedTime]),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                'location_label'.tr(args: [appointment['location']]),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                'created_by_label'
                    .tr(args: [appointment['familyNameWhoCreatedAppointemnt']]),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close'.tr(),
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff3B5998), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            top: _position,
            left: -100,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            bottom: -_position,
            right: -100,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          // Main content
          isLoading
              ? const Center(child: CircularProgressIndicator())
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
                            title: Text('Appointments'.tr()),
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            pinned: true,
                            leading: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const mainpatient(),
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
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: ListTile(
                                          leading: const Icon(
                                              Icons.calendar_today_rounded,
                                              color: Color(0xff3B5998)),
                                          title: Text(
                                            appointment['notes'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(
                                            _formatDateTime(DateTime.parse(
                                                appointment[
                                                    'date'])), // Format DateTime including time and AM/PM
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          trailing: const Icon(
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

  String _formatDateTime(DateTime dateTime) {
    // Use the DateFormat class from intl package to format the date and time
    return DateFormat('MMMM dd, yyyy - hh:mm a').format(dateTime);
  }
}
