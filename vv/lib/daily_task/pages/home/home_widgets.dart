import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../common/entities/task.dart';
import '../../common/values/constant.dart';

Widget buildBigText({required String title, Color color = Colors.white}) {
  return Text(
    title,
    style: TextStyle(
      color: color,
      fontSize: 20,
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
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.only(bottom: 10, left: 7, right: 5),
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 232, 232, 232),
          borderRadius: BorderRadius.circular(15),
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
                    padding: const EdgeInsets.only(left: 10, top: 8),
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black, // Set text color to black
                      ),
                    ),
                  ),
                ),
                Checkbox(value: done, onChanged: onChanged),
              ],
            ),
            const SizedBox(
              height: 7,
            ),
            if (repeat != AppConstant.INITIAL_RECURRENCE)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Repeat ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.repeat,
                        size: 16,
                        color: Colors.green,
                      )
                    ],
                  ),
                  repeat == 'Weekly'.tr()
                      ? Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Text(
                            'every_day_of_week'.tr(args: [dayOfWeek]),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        )
                      : repeat == 'Daily'.tr()
                          ? Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: Text(
                                'Every Day At $hours$minute'.tr(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: Text(
                                'Every Hour'.tr(),
                                style: const TextStyle(
                                  fontSize: 16,
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
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Overdue :  '.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Text(
                      '$dayOfWeek, $day$month$year, $hours$minute',
                      style: const TextStyle(
                        fontSize: 16,
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
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Due Date :  '.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Text(
                      '$dayOfWeek, $day$month$year, $hours$minute',
                      style: const TextStyle(
                        fontSize: 16,
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
