import 'package:flutter/material.dart';

import 'package:vv/models/task.dart';
import 'package:vv/page/task_screens/category_model.dart';
import 'package:vv/widgets/task_widgets/Edit_timepicker.dart';
import 'package:vv/widgets/task_widgets/appbarscreens.dart';


class TaskDetailsScreen extends StatefulWidget {
  List<CategoryModel> categories = CategoryModel.getCategories();
  final Task task;
  final Function(Task) onTaskUpdated;

  TaskDetailsScreen({
    required this.task,
    required this.onTaskUpdated,
  });

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late TextEditingController taskNameController;
   late TextEditingController medicationTypeController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  late TextEditingController descriptionController;
  bool _isEditing = false;
   int _selectedCategoryIndex = -1;

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
    taskNameController = TextEditingController(text: widget.task.name);
      medicationTypeController =
        TextEditingController(text: widget.task.categories);
    startTimeController = TextEditingController(text: widget.task.startTime);
    endTimeController = TextEditingController(text: widget.task.endTime);
    descriptionController =
        TextEditingController(text: widget.task.description);
  }

  void _disposeControllers() {
    taskNameController.dispose();
    medicationTypeController.dispose();
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
      Task editedTask = Task(
        name: taskNameController.text,
         categories: medicationTypeController.text,
        startTime: startTimeController.text,
        endTime: endTimeController.text,
        description: descriptionController.text,
        day: widget.task.day,
        completed: widget.task.completed,
      );
      widget.onTaskUpdated(editedTask);
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
      appBar: buildAppBar('Medicines'),
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
            Row(
              children: [
                BackButton(),
                Spacer(),
                IconButton(
                  icon: Icon(
                    _isEditing ? Icons.save : Icons.edit,
                    color: Colors.black,
                  ),
                  onPressed: _isEditing ? _saveChanges : _toggleEditing,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: taskNameController,
                enabled: _isEditing,
                decoration: InputDecoration(labelText: 'Medicine Name'),
              ),
            ),
             SizedBox(height: 10),
          Padding(
           padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: medicationTypeController,
                enabled: _isEditing,
                decoration: InputDecoration(labelText: 'Categories'),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(39.0),
                  topRight: Radius.circular(39.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TimePickerButton(
                                controller: startTimeController,
                                label: 'Start Time',
                                isEditing: _isEditing,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TimePickerButton(
                                controller: endTimeController,
                                label: 'End Time',
                                isEditing: _isEditing,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: descriptionController,
                          enabled: _isEditing,
                          decoration: InputDecoration(labelText: 'Description (optional)'),
                          maxLines: null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
