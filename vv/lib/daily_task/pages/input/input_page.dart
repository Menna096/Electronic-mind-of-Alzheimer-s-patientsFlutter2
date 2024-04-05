import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vv/daily_task/common/values/constant.dart';
import 'package:vv/daily_task/pages/home/home_page.dart';
import 'package:vv/daily_task/pages/input/bloc/input_bloc.dart';
import 'package:vv/daily_task/pages/input/bloc/input_event.dart';
import 'package:vv/daily_task/pages/input/input_controller.dart';
import 'package:vv/daily_task/pages/input/input_widgets.dart';

import 'bloc/input_state.dart';

class InputPage extends StatefulWidget {
  const InputPage({Key? key}) : super(key: key);

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  late InputController inputController;

  @override
  void initState() {
    super.initState();
    inputController = InputController(context: context);
    inputController.init();
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
          children: const [
            Text(
              'New Task',
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
                        buildHeadingText(title: 'What is to be done?'),
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
                        buildHeadingText(title: 'Add to list'),
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
                        buildHeadingText(title: 'Recurrence'),
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
                                'What is your deadline?',
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
                                        'Due date : ',
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
                                        'Due time : ',
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
        tooltip: 'Done',
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}
