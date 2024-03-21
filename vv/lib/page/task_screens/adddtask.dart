import 'package:flutter/material.dart';
import 'package:temp/widgets/backbutton.dart';
import '../../widgets/appbarscreens.dart';
import '../../widgets/name_textfield.dart';
import '../../widgets/details_container.dart';
import '../../widgets/timeselectraw.dart';
import '../../widgets/timeselectcontainer.dart';
import '../../widgets/add_button.dart';
import '../../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  final Function(Task) onTaskAdded;

  const AddTaskScreen({required this.onTaskAdded});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late TextEditingController taskNameController;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  late TextEditingController descriptionController;
  int selectedDayIndex = 1;
  Color pickedColor = Color(0xFF0386D0);

  @override
  void initState() {
    super.initState();
    taskNameController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    taskNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar('Daily Tasks'),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Container(
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
          backbutton(),
          TaskNameTextField(
            controller: taskNameController,
            labelText: 'Nmae',
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(39.0),
                topRight: Radius.circular(39.0),
              ),
              child: TaskDetailsContainer(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    TimeSelectionRow(
                      children: [
                        Spacer(
                          flex: 4,
                        ),
                        TimeSelectionContainer(
                          label: 'Start Time',
                          onPressed: () => _selectStartTime(context),
                          time: startTime,
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        TimeSelectionContainer(
                          label: 'End Time',
                          onPressed: () => _selectEndTime(context),
                          time: endTime,
                        ),
                        Spacer(
                          flex: 4,
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Divider(
                      indent: 75,
                      endIndent: 75,
                      color: Colors.black,
                    ),
                    Expanded(
                      child: TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    AddTaskButton(
                      onPressed: () {
                        if (validateInputs()) {
                          Task newTask = Task(
                            name: taskNameController.text,
                            startTime: startTime != null
                                ? '${startTime!.hour}:${startTime!.minute}'
                                : '',
                            endTime: endTime != null
                                ? '${endTime!.hour}:${endTime!.minute}'
                                : '',
                            description: descriptionController.text,
                            day: selectedDayIndex,
                            completed: false,
                          );
                          widget.onTaskAdded(newTask);
                          Navigator.pop(context);
                        }
                      },
                      backgroundColor: pickedColor,
                      buttonText: 'Add text',
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool validateInputs() {
    if (taskNameController.text.isEmpty ||
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
