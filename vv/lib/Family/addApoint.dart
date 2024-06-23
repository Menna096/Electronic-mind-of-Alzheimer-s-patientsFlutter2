import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:vv/Family/appoint_list.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/background.dart';
import 'package:vv/widgets/task_widgets/add_button.dart';
import 'package:vv/widgets/task_widgets/details_container.dart';
import 'package:vv/widgets/task_widgets/name_textfield.dart';
import 'package:vv/widgets/task_widgets/timeselectcontainer.dart';
import 'package:vv/widgets/task_widgets/timeselectraw.dart';

class APIService {
  static final Dio _dio = Dio();

  static Future<dynamic> register(String jsonData) async {
    try {
      _dio.options.headers['accept'] = 'application/json';
      _dio.options.headers['content-type'] = 'application/json';
      Response response = await DioService().dio.post(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/AddAppointment',
        data: jsonData,
      );
      return response.statusCode == 200
          ? true
          : response.data != null && response.data['message'] != null
              ? response.data['message']
              : 'Add failed with status code: ${response.statusCode}';
    } catch (error) {
      print('Add failed: $error');
      return 'Add failed'.tr();
    }
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings settings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(settings);

    print("Notifications initialized");
  }

  static Future<void> scheduleAppointmentNotification(
      DateTime scheduledTime, String appointmentName) async {
    print(
        "Scheduling notification at $scheduledTime for appointment $appointmentName");

    var androidDetails = const AndroidNotificationDetails(
        'appointment_id', 'appointment_notifications',
        importance: Importance.max, priority: Priority.high);
    var platformDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.zonedSchedule(
        0,
        'Appointment Reminder'.tr(),
        'You have an appointment: $appointmentName'.tr(),
        tz.TZDateTime.from(scheduledTime, tz.local),
        platformDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);

    print("Notification scheduled");
  }
}

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen();

  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  TimeOfDay? startTime;
  DateTime? selectedDate;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  int selectedDayIndex = 1;
  Color pickedColor = const Color(0xFF0386D0);
  late bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    NotificationService.init();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  void _load() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });
    try {
      if (_locationController.text.isEmpty || _noteController.text.isEmpty) {
        throw 'Please fill in all fields'.tr();
      }
      if (startTime == null || selectedDate == null) {
        throw 'Please select both start time and start day'.tr();
      }

      final DateTime combinedDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        startTime!.hour,
        startTime!.minute,
      );

      final Map<String, dynamic> requestData = {
        'date': combinedDateTime.toIso8601String(),
        'location': _locationController.text,
        'notes': _noteController.text,
      };
      String jsonData = jsonEncode(requestData);

      dynamic response = await APIService.register(jsonData);

      if (response == true) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Add Appointment Successful'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AppointListScreen()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw 'Add failed.\nsomething went wrong try again later ';
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Failed'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AppointListScreen()),
            );
          },
        ),
        title: Text(
          "Add Appointment",
          style: TextStyle(
            fontFamily: 'LilitaOne',
            fontSize: 23,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50.0),
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: buildBody(),
    );
  }

  Widget buildBody() {
    String? formattedSelectedDate = selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
        : null;

    return Background(
      SingleChildScrollView: null,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            // Location Input
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 235, 242, 255),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Add Location',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.location_pin),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Notes Input
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 235, 242, 255),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: 'Add Notes',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Start Time Selection
            GestureDetector(
              onTap: () => _selectStartTime(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 235, 242, 255),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      color: Color(0xFF6A95E9),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        startTime != null
                            ? formatTimeOfDay(startTime!)
                            : 'Select Start Time',
                        style: TextStyle(fontSize: 16, fontFamily: 'Acme'),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF6A95E9),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Start Date Selection
            GestureDetector(
              onTap: () => _selectStartDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 235, 242, 255),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF6A95E9),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        formattedSelectedDate ?? 'Select Start Date',
                        style: TextStyle(fontSize: 16, fontFamily: 'Acme'),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF6A95E9),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40.0),

            // Add Appointment Button (Centered)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _load();
                  if (startTime != null && selectedDate != null) {
                    DateTime startDateTime = DateTime(
                      selectedDate!.year,
                      selectedDate!.month,
                      selectedDate!.day,
                      startTime!.hour,
                      startTime!.minute,
                    );
                    NotificationService.scheduleAppointmentNotification(
                      startDateTime,
                      _locationController.text,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 58, 157, 50), // Changed color
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }

  bool validateInputs() {
    if (_locationController.text.isEmpty ||
        _noteController.text.isEmpty ||
        startTime == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please fill in all fields.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        startTime = picked;
      });
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}