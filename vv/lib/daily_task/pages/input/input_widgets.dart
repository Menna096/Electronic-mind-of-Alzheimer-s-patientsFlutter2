import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:vv/daily_task/common/values/constant.dart';

Widget buildHeadingText({required String title}) {
  return Text(
    title,
    style: TextStyle(
      color: const Color.fromARGB(255, 76, 131, 198),
      fontSize: 20.sp,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget buildTaskField({required Function(String)? onChanged}) {
  return TextFormField(
    onChanged: onChanged,
    minLines: 2,
    maxLines: 4,
    keyboardType: TextInputType.multiline,
    decoration: InputDecoration(
      hintText: 'Enter Task Here'.tr(),
      hintStyle: const TextStyle(color: Colors.grey),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: const Color(0xff3B5998), width: 2.0.w),
        borderRadius: BorderRadius.circular(16.0.w),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0.w)),
      ),
    ),
  );
}

Widget buildDateTimePicker(
    {required BuildContext context,
    required void Function(DateTime?) onDateTimeChanged}) {
  return Container(
    height: 100.h,
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: const Color.fromARGB(255, 219, 219, 219),
          width: 2.w,
        ),
        bottom: BorderSide(
          color: const Color.fromARGB(255, 219, 219, 219),
          width: 2.w,
        ),
        left: BorderSide(
          color: const Color.fromARGB(255, 219, 219, 219),
          width: 2.w,
        ),
        right: BorderSide(
          color: const Color.fromARGB(255, 219, 219, 219),
          width: 2.w,
        ),
      ),
      borderRadius: BorderRadius.all(Radius.circular(16.0.w)),
    ),
    child: CupertinoDatePicker(
      mode: CupertinoDatePickerMode.dateAndTime,
      minimumDate: DateTime.now().subtract(const Duration(days: 0)),
      initialDateTime: DateTime.now(),
      onDateTimeChanged: onDateTimeChanged,
      use24hFormat: false,
      minuteInterval: 1,
    ),
  );
}

Widget buildDropDown(
    {required BuildContext context,
    required String selectedValue,
    required String inital,
    required List<String> dropDownList,
    required Function(String?)? onChanged}) {
  return DropdownButton(
    hint: Text(
      selectedValue,
    ),
    isExpanded: true,
    iconSize: 30.0.w,
    dropdownColor: const Color.fromARGB(255, 92, 129, 208),
    iconEnabledColor: const Color.fromARGB(255, 64, 64, 65),
    borderRadius: BorderRadius.circular(16.0),
    style: TextStyle(color: Colors.white, fontSize: 18.sp),
    items: dropDownList.map(
      (val) {
        return DropdownMenuItem<String>(
          value: val,
          child: Text(val),
        );
      },
    ).toList(),
    onChanged: onChanged,
  );
}

Widget buildDurationText(String? duration) {
  String? intervalText;
  if (duration == AppConstant.RECURRENCE[1]) {
    intervalText = 'Every hour from now on'.tr();
  }
  if (duration == AppConstant.RECURRENCE[2]) {
    intervalText = 'Every day from today'.tr();
  }
  if (duration == AppConstant.RECURRENCE[3]) {
    intervalText =
        'every_day_of_week'.tr(args: [DateFormat('EEEE').format(DateTime.now())]);
  }
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      buildHeadingText(title: 'Repeat :'.tr()),
      Row(
        children: [
          Icon(
            Icons.repeat_on,
            color: Colors.white,
            size: 18.w,
          ),
          SizedBox(
            width: 5.0.w,
          ),
          buildAlarmText(text: intervalText),
        ],
      ),
    ],
  );
}

Widget buildAlarmText({String? text}) {
  return Text(
    text ?? '',
    overflow: TextOverflow.fade,
    style: TextStyle(
      color: Colors.white,
      fontSize: 18.w,
    ),
  );
}
