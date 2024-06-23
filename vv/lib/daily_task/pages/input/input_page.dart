import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vv/daily_task/common/values/constant.dart';
import 'package:vv/daily_task/pages/home/home_page.dart';
import 'package:vv/daily_task/pages/input/bloc/input_bloc.dart';
import 'package:vv/daily_task/pages/input/bloc/input_event.dart';
import 'package:vv/daily_task/pages/input/input_controller.dart';
import 'package:vv/daily_task/pages/input/input_widgets.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:geolocator/geolocator.dart';

import 'bloc/input_state.dart';

class InputPage extends StatefulWidget {
  const InputPage({Key? key}) : super(key: key);

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  late InputController inputController;
   late HubConnection _connection;
  Timer? _locationTimer; // Initialize Dio


  @override
  void initState() {
    super.initState();
    initializeSignalR();
    inputController = InputController(context: context);
    inputController.init();
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Color.fromARGB(255, 244, 244, 244),
            height: 1.0.h,
          ),
        ),
        scrolledUnderElevation: 0,
        backgroundColor: Color.fromARGB(255, 150, 190, 251),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:  [
            Text(
              'New Task'.tr(),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(width: 16.0), // Adjust spacing as needed
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
        child: BlocBuilder<InputBloc, InputState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 20.0.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildHeadingText(title: 'What is to be done?'.tr()),
                        SizedBox(height: 10.h),
                        buildTaskField(
                          onChanged: (task) {
                            context
                                .read<InputBloc>()
                                .add(TaskEvent(task: task));
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildHeadingText(title: 'Add to list'.tr()),
                        SizedBox(
                          height: 10.h,
                        ),
                        buildDropDown(
                          context: context,
                          selectedValue: state.list ?? AppConstant.INITIAL_LIST,
                          inital: AppConstant.INITIAL_LIST,
                          dropDownList: AppConstant.LIST,
                          onChanged: (list) {
                            context
                                .read<InputBloc>()
                                .add(ListEvent(list: list));
                          },
                        )
                      ],
                    ),
                    SizedBox(height: 30.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildHeadingText(title: 'Recurrence'.tr()),
                        SizedBox(
                          height: 10.h,
                        ),
                        buildDropDown(
                          context: context,
                          selectedValue:
                              state.duration ?? AppConstant.INITIAL_RECURRENCE,
                          inital: AppConstant.INITIAL_RECURRENCE,
                          dropDownList: AppConstant.RECURRENCE,
                          onChanged: (duration) {
                            context
                                .read<InputBloc>()
                                .add(RecurrenceEvent(duration: duration));
                          },
                        )
                      ],
                    ),
                    SizedBox(height: 30.h),
                    state.duration == AppConstant.INITIAL_RECURRENCE
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What is your deadline?'.tr(),
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 221, 221, 221),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              buildDateTimePicker(
                                context: context,
                                onDateTimeChanged: (dateTime) {
                                  context.read<InputBloc>().add(
                                      DateAndTimeEvent(dateTime: dateTime));
                                },
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Due date : '.tr(),
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              255, 221, 221, 221),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: Color.fromARGB(
                                                255, 219, 219, 219),
                                            size: 18.w,
                                          ),
                                          SizedBox(
                                            width: 5.0.w,
                                          ),
                                          buildAlarmText(
                                              text:
                                                  '${state.dateTime!.day.toString()}/${state.dateTime!.month.toString()}/${state.dateTime!.year.toString()}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Due time : '.tr(),
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              255, 221, 221, 221),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.timer,
                                            color: Color.fromARGB(
                                                255, 219, 219, 219),
                                            size: 18.w,
                                          ),
                                          SizedBox(
                                            width: 5.0.w,
                                          ),
                                          state.dateTime!.minute < 10
                                              ? buildAlarmText(
                                                  text:
                                                      '${state.dateTime!.hour.toString()}:0${state.dateTime!.minute.toString()}')
                                              : buildAlarmText(
                                                  text:
                                                      '${state.dateTime!.hour.toString()}:${state.dateTime!.minute.toString()}'),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          )
                        : buildDurationText(state.duration),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 128, 171, 236),
        onPressed: () {
          inputController.generateTask();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const Home()));
        },
        tooltip: 'Done'.tr(),
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}
