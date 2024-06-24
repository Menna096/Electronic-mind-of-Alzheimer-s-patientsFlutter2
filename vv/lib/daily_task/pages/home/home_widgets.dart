import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../common/entities/task.dart';
import '../../common/values/constant.dart';

Widget buildBigText({required String title, Color color = Colors.white}) {
  return Text(
    title,
    style: TextStyle(
      color: color,
      fontSize: 20.sp,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget buildTask({
  required Task task,
  required bool? done,
  required void Function(bool?) onChanged,
}) {
  var text = task.body;
  var repeat = task.recurrence;
  var time = task.dateTime;
  var date = DateTime.fromMillisecondsSinceEpoch(time * 1000);
  bool overdue = DateTime.now().isAfter(date);
  var hours = '${date.hour}:';

  var minute = '${date.minute}';
  if (date.minute < 10) {
    minute = '0${date.minute}';
  }

  var day = '${date.day}/';
  var month = '${date.month}/';
  var year = '${date.year}';
  var dayOfWeek = DateFormat('EEEE').format(date);

  return Stack(
    alignment: Alignment.center,
    children: [
      Container(
        margin: EdgeInsets.all(10.w),
        padding: EdgeInsets.only(bottom: 10.w, left: 7.w, right: 5.w),
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 232, 232, 232),
          borderRadius: BorderRadius.circular(15.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.w, top: 8.h),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.black, // Set text color to black
                      ),
                    ),
                  ),
                ),
                Checkbox(value: done, onChanged: onChanged),
              ],
            ),
            SizedBox(
              height: 7.h,
            ),
            if (repeat != AppConstant.INITIAL_RECURRENCE)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10.w),
                        child: Text(
                          'Repeat ',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.repeat,
                        size: 16.w,
                        color: Colors.green,
                      )
                    ],
                  ),
                  repeat == 'Weekly'.tr()
                      ? Padding(
                          padding: EdgeInsets.only(right: 14.w),
                          child: Text(
                            'every_day_of_week'.tr(args: [dayOfWeek]),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.green,
                            ),
                          ),
                        )
                      : repeat == 'Daily'.tr()
                          ? Padding(
                              padding: EdgeInsets.only(right: 14.w),
                              child: Text(
                                'Every Day At $hours$minute'.tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.green,
                                ),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.only(right: 14.w),
                              child: Text(
                                'Every Hour'.tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                ],
              )
            else if (overdue)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.w),
                    child: Text(
                      'Overdue :  '.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 14.w),
                    child: Text(
                      '$dayOfWeek, $day$month$year, $hours$minute',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.w),
                    child: Text(
                      'Due Date :  '.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 14.w),
                    child: Text(
                      '$dayOfWeek, $day$month$year, $hours$minute',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ],
  );
}
