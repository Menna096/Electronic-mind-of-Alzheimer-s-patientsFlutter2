import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  const InputPage({super.key});

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
      backgroundColor: const Color(0xff3B5998),
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color.fromARGB(255, 244, 244, 244),
            height: 1.0,
          ),
        ),
        scrolledUnderElevation: 0,
        backgroundColor: const Color.fromARGB(255, 150, 190, 251),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'New Task'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 16.0), // Adjust spacing as needed
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFFFFF), Color(0xff3B5998), Color(0xff3B5998)],
          ),
        ),
        child: BlocBuilder<InputBloc, InputState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.only(
                  right: 16,
                  left: 16,
                  top: 20,
                  bottom: MediaQuery.of(context).size.height * 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildHeadingText(title: 'What is to be done?'.tr()),
                        const SizedBox(height: 10),
                        buildTaskField(
                          onChanged: (task) {
                            context
                                .read<InputBloc>()
                                .add(TaskEvent(task: task));
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildHeadingText(title: 'Add to list'.tr()),
                        const SizedBox(
                          height: 10,
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
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildHeadingText(title: 'Recurrence'.tr()),
                        const SizedBox(
                          height: 10,
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
                  ),
                  Expanded(
                    child: Visibility(
                      visible: state.duration == AppConstant.INITIAL_RECURRENCE,
                      replacement: buildDurationText(state.duration),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'What is your deadline?'.tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 221, 221, 221),
                            ),
                          ),
                          buildDateTimePicker(
                            context: context,
                            onDateTimeChanged: (dateTime) {
                              context
                                  .read<InputBloc>()
                                  .add(DateAndTimeEvent(dateTime: dateTime));
                            },
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Due date : '.tr(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 221, 221, 221),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color:
                                            Color.fromARGB(255, 219, 219, 219),
                                        size: 18,
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
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 221, 221, 221),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.timer,
                                        color:
                                            Color.fromARGB(255, 219, 219, 219),
                                        size: 18,
                                      ),
                                      const SizedBox(
                                        width: 5.0,
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
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 128, 171, 236),
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
