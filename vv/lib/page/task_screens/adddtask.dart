import 'package:flutter/material.dart';
import 'package:vv/widgets/task_widgets/add_button.dart';
import 'package:vv/widgets/task_widgets/details_container.dart';
import 'package:vv/widgets/task_widgets/name_textfield.dart';
import 'package:vv/widgets/task_widgets/timeselectcontainer.dart';
import 'package:vv/widgets/task_widgets/timeselectraw.dart';
import 'package:vv/page/task_screens/category_model.dart';


import '../../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  List<CategoryModel> categories = CategoryModel.getCategories();
  final Function(Task) onTaskAdded;

  AddTaskScreen({required this.onTaskAdded});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late TextEditingController taskNameController;
  late TextEditingController medicationTypeController;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  late TextEditingController descriptionController;
  int selectedDayIndex = 1;
    int _selectedCategoryIndex = -1;
  Color pickedColor = Color(0xFF0386D0);

  @override
  void initState() {
    super.initState();
    taskNameController = TextEditingController();
    medicationTypeController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    taskNameController.dispose();
      medicationTypeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Medicine',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 5,
        backgroundColor: Color.fromARGB(255, 112, 193, 255),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
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
         
          TaskNameTextField(
            controller: taskNameController,
            labelText: 'Medicine Name',
          ),
           SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(left: 15, right: 0),
            child: Text(
              'Categories',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: ListView.builder(
              itemCount: widget.categories.length,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 0, right: 20),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (_selectedCategoryIndex == index) {
                          // If the same category is tapped again, deselect it
                        } else {
                          // Deselect the previously selected category
                          if (_selectedCategoryIndex != -1) {
                            widget.categories[_selectedCategoryIndex]
                                .boxColor =
                                Color.fromARGB(255, 226, 226, 226);
                            widget.categories[_selectedCategoryIndex]
                                .isSelected = false;
                          }

                          // Select the tapped category
                          _selectedCategoryIndex = index;
                          medicationTypeController.text =
                              widget.categories[index].name;
                          widget.categories[index].boxColor =
                              Color.fromARGB(255, 0, 0, 0).withOpacity(0.3);
                          widget.categories[index].isSelected = true;
                        }
                      });
                    },
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: widget.categories[index].boxColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                widget.categories[index].iconPath,
                              ),
                            ),
                          ),
                          Text(
                            widget.categories[index].name,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
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
                        decoration: InputDecoration(labelText: 'Description (optional)'),
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
                            categories: medicationTypeController.text,
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
                      backgroundColor: Color.fromARGB(255, 112, 193, 255),
                      buttonText: 'Add Medicine',
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
    if (taskNameController.text.isEmpty || medicationTypeController.text.isEmpty ||
        (startTime == null || endTime == null)) {
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
