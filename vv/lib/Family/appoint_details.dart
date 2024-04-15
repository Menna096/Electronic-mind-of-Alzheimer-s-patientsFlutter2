import 'package:flutter/material.dart';

import 'package:vv/models/appoint.dart';
import 'package:vv/widgets/task_widgets/Edit_timepicker.dart';
import 'package:vv/widgets/task_widgets/appbarscreens.dart';

class AppointDetailsScreen extends StatefulWidget {
  final Appointment appoint;

  AppointDetailsScreen({
    required this.appoint,
    required Null Function(dynamic editedAppoint) onAppointUpdated,
  });

  @override
  _AppointDetailsScreenState createState() => _AppointDetailsScreenState();
}

class _AppointDetailsScreenState extends State<AppointDetailsScreen> {
  late TextEditingController appointNameController;
  late TextEditingController placeController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  late TextEditingController descriptionController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _initializeControllers() {
    appointNameController = TextEditingController(text: widget.appoint.name);
    placeController = TextEditingController(text: widget.appoint.place);
    startTimeController = TextEditingController(text: widget.appoint.startTime);
    endTimeController = TextEditingController(text: widget.appoint.endTime);
    descriptionController =
        TextEditingController(text: widget.appoint.description);
  }

  void _disposeControllers() {
    appointNameController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    descriptionController.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    if (_validateInputs()) {
      Appointment editedAppoint = Appointment(
        name: appointNameController.text,
        place: placeController.text,
        startTime: startTimeController.text,
        endTime: endTimeController.text,
        description: descriptionController.text,
        day: widget.appoint.day,
        completed: widget.appoint.completed,
      );

      Navigator.pop(context);
    }
  }

  bool _validateInputs() {
    // Implement your validation logic here
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: buildAppBar('Appointments'),
      body: Container(
        alignment: AlignmentDirectional.bottomCenter,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffFFFFFF),
              Color(0xff3B5998),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            Center(
              child: Text(
                'Appointments',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
            Row(
              children: [
                BackButton(),
                Spacer(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: TextField(
                controller: appointNameController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: TextField(
                controller: placeController,
                decoration: InputDecoration(labelText: 'Place'),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 8.0),
                    child: TextField(
                      controller: startTimeController,
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        suffixIcon: Icon(
                            Icons.timer), // Optional: adds timer icon as suffix
                      ),
                      onTap: () {
                        // Implement your logic to pick time
                        // Example: showTimePicker(context: context, initialTime: TimeOfDay.now())
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 8.0),
                    child: TextField(
                      controller: endTimeController,
                      decoration: InputDecoration(
                        labelText: 'End Time',
                        suffixIcon: Icon(
                            Icons.timer), // Optional: adds timer icon as suffix
                      ),
                      onTap: () {
                        // Implement your logic to pick time
                        // Example: showTimePicker(context: context, initialTime: TimeOfDay.now())
                      },
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 8.0),
                    child: TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
