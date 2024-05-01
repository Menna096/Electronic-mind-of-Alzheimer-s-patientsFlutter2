import 'dart:convert';
import 'package:dio/dio.dart';
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
      return 'Add failed: $error';
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
//
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
        'Appointment Reminder',
        'You have an appointment: $appointmentName',
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
  Color pickedColor = Color(0xFF0386D0);
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
    final now = new DateTime.now();
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
      if (_locationController.text.isEmpty ||
          _noteController.text.isEmpty) {
        throw 'Please fill in all fields';
      }
      if (startTime == null || selectedDate == null) {
        throw 'Please select both start time and start day';
      }

      final Map<String, dynamic> requestData = {
        'date': selectedDate!.toIso8601String(),
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
                    MaterialPageRoute(builder: (context) => AppointListScreen()),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Center(
              child: Text(
                'Appointments',
                style: TextStyle(fontSize: 30),
              ),
            ),
            backbutton(),
            TaskNameTextField(
              controller: _locationController,
              labelText: 'Location',
            ),
            TaskNameTextField(controller: _noteController, labelText: 'Notes'),
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(39.0),
                topRight: Radius.circular(39.0),
              ),
              child: TaskDetailsContainer(
                child: Column(
                  children: [
                    TimeSelectionRow(
                      children: [
                        Spacer(flex: 4),
                        TimeSelectionContainer(
                          label: 'Start Time',
                          onPressed: () => _selectStartTime(context),
                          time: startTime,
                        ),
                        Spacer(flex: 4),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _selectStartDate(context),
                      child: Text('Select Start Date'),
                    ),
                    SizedBox(height: 10),
                    // Conditionally render the text based on selectedDate
                    if (formattedSelectedDate != null)
                      Text(
                        'Selected Date: $formattedSelectedDate',
                        style: TextStyle(fontSize: 16),
                      )
                    else
                      Container(), // Empty container if no date is selected
                    SizedBox(height: 200.0),
                    AddTaskButton(
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
                      backgroundColor: pickedColor,
                      buttonText: 'Add Appointment',
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
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
          title: Text('Error'),
          content: Text('Please fill in all fields.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
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
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}
