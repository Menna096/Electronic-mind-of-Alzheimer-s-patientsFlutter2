import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vv/models/appoint.dart';
import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/background.dart';
import 'package:vv/widgets/task_widgets/add_button.dart';
import 'package:vv/widgets/task_widgets/details_container.dart';
import 'package:vv/widgets/task_widgets/name_textfield.dart';
import 'package:vv/widgets/task_widgets/timeselectcontainer.dart';
import 'package:vv/widgets/task_widgets/timeselectraw.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
  final Function(Appointment) onAppointAdded;

  const AddAppointmentScreen({required this.onAppointAdded});

  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  late TextEditingController appointNameController;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  late TextEditingController descriptionController;
  late TextEditingController placeController;
  int selectedDayIndex = 1;
  Color pickedColor = Color(0xFF0386D0);

  @override
  void initState() {
    super.initState();
    appointNameController = TextEditingController();
    descriptionController = TextEditingController();
    placeController = TextEditingController();
    NotificationService.init();
  }

  @override
  void dispose() {
    appointNameController.dispose();
    descriptionController.dispose();
    placeController.dispose();
    super.dispose();
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: buildAppBar('Appointments'),
      resizeToAvoidBottomInset: true,
      body: buildBody(),
    );
  }

  Widget buildBody() {
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
              controller: appointNameController,
              labelText: 'Title',
            ),
            TaskNameTextField(controller: placeController, labelText: 'Place'),
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
                        Spacer(flex: 1),
                        TimeSelectionContainer(
                          label: 'End Time',
                          onPressed: () => _selectEndTime(context),
                          time: endTime,
                        ),
                        Spacer(flex: 4),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                    SizedBox(height: 200.0),
                    AddTaskButton(
                      onPressed: () {
                        if (startTime != null) {
                          DateTime now = DateTime.now();
                          DateTime startDateTime = DateTime(now.year, now.month,
                              now.day, startTime!.hour, startTime!.minute);
                          NotificationService.scheduleAppointmentNotification(
                              startDateTime, appointNameController.text);
                        }
                        if (validateInputs()) {
                          DateTime startDate = DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                              startTime!.hour,
                              startTime!.minute);
                          Appointment newAppoint = Appointment(
                            name: appointNameController.text,
                            place: placeController.text,
                            startTime: formatTimeOfDay(startTime!),
                            endTime: formatTimeOfDay(endTime!),
                            description: descriptionController.text,
                            day: selectedDayIndex,
                            completed: false,
                          );
                          widget.onAppointAdded(newAppoint);
                          NotificationService.scheduleAppointmentNotification(
                              startDate, appointNameController.text);
                          Navigator.pop(context);
                        }
                      },
                      backgroundColor: pickedColor,
                      buttonText: 'Add appointment',
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
    if (appointNameController.text.isEmpty ||
        placeController.text.isEmpty ||
        (startTime == null || endTime == null) ||
        descriptionController.text.isEmpty) {
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

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        endTime = picked;
      });
    }
  }
}