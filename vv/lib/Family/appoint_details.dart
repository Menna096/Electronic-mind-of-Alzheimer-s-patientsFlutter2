import 'package:easy_localization/easy_localization.dart';
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
  late TextEditingController _locationController;
  late TextEditingController _noteController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
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
    _locationController = TextEditingController(text: widget.appoint.location);
    _noteController = TextEditingController(text: widget.appoint.note);
    startTimeController = TextEditingController(text: widget.appoint.startTime);
  
  }

  void _disposeControllers() {
    _locationController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    if (_validateInputs()) {
      Appointment editedAppoint = Appointment(
        location: _locationController.text,
        note: _noteController.text,
        startTime: startTimeController.text,
       
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
                'Appointments'.tr(),
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
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'.tr()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: TextField(
                controller: _noteController,
                decoration: InputDecoration(labelText: 'Notes'.tr()),
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
                        labelText: 'Start Time'.tr(),
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
                        labelText: 'End Time'.tr(),
                        suffixIcon: Icon(
                            Icons.timer), // Optional: adds timer icon as suffix
                      ),
                      onTap: () {
                        // Implement your logic to pick time
                        // Example: showTimePicker(context: context, initialTime: TimeOfDay.now())
                      },
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
//