import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:vv/daily_task/common/database/task_database.dart';
import 'package:vv/daily_task/common/entities/task.dart';
import 'package:vv/daily_task/common/values/constant.dart';
import 'package:vv/daily_task/pages/home/bloc/home_bloc.dart';
import 'package:vv/daily_task/pages/home/bloc/home_state.dart';
import 'package:vv/daily_task/pages/input/input_controller.dart';
import 'package:vv/daily_task/pages/input/input_page.dart';
import 'home_widgets.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:geolocator/geolocator.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
   late HubConnection _connection;
  Timer? _locationTimer; // Initialize Dio
  List<Task> tasks = [];
  List<Task> nonRepeatingTasks = [];
  List<Task> repeatingTasks = [];
  List<List<Task>> tasksList = [];
  List<Task> selectedTask = [];
  bool isLoading = false;

  Future<void> refreshTasks() async {
    setState(() => isLoading = true);
    tasks = await TasksDatabase.instance.readAllTasks();
    nonRepeatingTasks.clear();
    repeatingTasks.clear();
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].recurrence == AppConstant.INITIAL_RECURRENCE) {
        nonRepeatingTasks.add(tasks[i]);
      } else {
        repeatingTasks.add(tasks[i]);
      }
    }
    nonRepeatingTasks.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    tasksList = [nonRepeatingTasks, repeatingTasks];

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
     initializeSignalR();
    refreshTasks();
  }

  Future<void> initializeSignalR() async {
    final token = await TokenManager.getToken();
    _connection = HubConnectionBuilder()
        .withUrl(
      'https://electronicmindofalzheimerpatients.azurewebsites.net/hubs/GPS',
      HttpConnectionOptions(
        accessTokenFactory: () => Future.value(token),
        logging: (level, message) => print(message),
      ),
    )
        .withAutomaticReconnect(
            [0, 2000, 10000, 30000]) // Configuring automatic reconnect
        .build();

    _connection.onclose((error) async {
      print('Connection closed. Error: $error');
      // Optionally initiate a manual reconnect here if automatic reconnect is not sufficient
      await reconnect();
    });

    try {
      await _connection.start();
      print('SignalR connection established.');
      // Start sending location every minute after the connection is established
      _locationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        sendCurrentLocation();
      });
    } catch (e) {
      print('Failed to start SignalR connection: $e');
      await reconnect();
    }
  }

  Future<void> reconnect() async {
    int retryInterval = 1000; // Initial retry interval to 5 seconds
    while (_connection.state != HubConnectionState.connected) {
      await Future.delayed(Duration(milliseconds: retryInterval));
      try {
        await _connection.start();
        print("Reconnected to SignalR server.");
        return; // Exit the loop if connected
      } catch (e) {
        print("Reconnect failed: $e");
        retryInterval = (retryInterval < 1000)
            ? retryInterval + 1000
            : 1000; // Increase retry interval, cap at 1 seconds
      }
    }
  }

  Future<void> sendCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await _connection.invoke('SendGPSToFamilies',
          args: [position.latitude, position.longitude]);
      print('Location sent: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error sending location: $e');
    }
  }
    @override
  void dispose() {
    _locationTimer?.cancel(); // Cancel the timer when the widget is disposed
    _connection.stop(); // Optionally stop the connection
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff3B5998),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => mainpatient()),
            );
          },
        ),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.black,
            height: 0.0.h,
          ),
        ),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 128, 171, 236),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Aligning "Tasks" to the left
            const Text(
              'Tasks',
              style: TextStyle(color: Colors.white),
            ),
            // Aligning the other widget to the right (if any)
            SizedBox(width: 56.0), // Adjust the width as per your need
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFFFFF), Color(0xff3B5998)],
          ),
        ),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return isLoading
                ? const Center(child: CircularProgressIndicator())
                : tasks.isEmpty
                    ? const Center(
                        child: Text(
                          'No Tasks',
                          style: TextStyle(color: Color.fromARGB(255, 47, 47, 47), fontSize: 24),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: tasksList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              index == 0
                                  ? Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                        left: 10.w,
                                        top: 20.h,
                                      ),
                                      child: nonRepeatingTasks.isEmpty
                                          ? const SizedBox(
                                              width: 0,
                                              height: 0,
                                            )
                                          : Text('My Tasks'),
                                    )
                                  : Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                        left: 10.w,
                                        top: 30.h,
                                      ),
                                      child: repeatingTasks.isEmpty
                                          ? const SizedBox(
                                              width: 0,
                                              height: 0,
                                            )
                                          : buildBigText(title: 'REPEATED'),
                                    ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: tasksList[index].length,
                                itemBuilder: (BuildContext context, int i) {
                                  return buildTask(
                                    task: tasksList[index][i],
                                    done: selectedTask.contains(tasksList[index][i]),
                                    onChanged: (curValue) {
                                      if (selectedTask.contains(tasksList[index][i])) {
                                        selectedTask.remove(tasksList[index][i]);
                                      } else {
                                        selectedTask.add(tasksList[index][i]);
                                      }
                                      InputController(context: context).cancelNotification(tasksList[index][i].id!);
                                      TasksDatabase.instance.delete(tasksList[index][i].id!);
                                      refreshTasks(); // Refresh tasks after deletion
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Task completed",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
          },
        ),
      ),
      floatingActionButton: OpenContainer(
        transitionType: ContainerTransitionType.fadeThrough,
        closedElevation: 0.0,
        openElevation: 4.0,
        transitionDuration: const Duration(milliseconds: 1500),
        openBuilder: (BuildContext context, VoidCallback _) => const InputPage(),
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(56.0 / 2),
          ),
        ),
        closedColor: Color.fromARGB(255, 128, 171, 236),
        closedBuilder: (BuildContext context, VoidCallback openContainer) {
          return SizedBox(
            height: 56.0.h,
            width: 56.0.w,
            child: Center(
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          );
        },
      ),
    );
  }
}
