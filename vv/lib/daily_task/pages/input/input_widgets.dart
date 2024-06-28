import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:vv/daily_task/common/values/constant.dart';

Widget buildHeadingText({required String title}) {
  return Text(
    title,
    style: const TextStyle(
      color: Color.fromARGB(255, 76, 131, 198),
      fontSize: 20,
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
        borderSide: const BorderSide(color: Color(0xff3B5998), width: 2.0),
        borderRadius: BorderRadius.circular(16.0),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
    ),
  );
}

Widget buildDateTimePicker(
    {required BuildContext context,
    required void Function(DateTime?) onDateTimeChanged}) {
  return Container(
    height: 100,
    decoration: const BoxDecoration(
      border: Border(
        top: BorderSide(
          color: Color.fromARGB(255, 219, 219, 219),
          width: 2,
        ),
        bottom: BorderSide(
          color: Color.fromARGB(255, 219, 219, 219),
          width: 2,
        ),
        left: BorderSide(
          color: Color.fromARGB(255, 219, 219, 219),
          width: 2,
        ),
        right: BorderSide(
          color: Color.fromARGB(255, 219, 219, 219),
          width: 2,
        ),
      ),
      borderRadius: BorderRadius.all(Radius.circular(16.0)),
    ),
    child: CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.dateAndTime,
        minimumDate: DateTime.now().subtract(const Duration(days: 0)),
        initialDateTime: DateTime.now(),
        onDateTimeChanged: onDateTimeChanged,
        use24hFormat: false,
        minuteInterval: 1,
      ),
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
      style: const TextStyle(color: Colors.white),
    ),
    isExpanded: true,
    iconSize: 30.0,
    dropdownColor: const Color.fromARGB(255, 92, 129, 208),
    iconEnabledColor: Colors.white,
    borderRadius: BorderRadius.circular(16.0),
    style: const TextStyle(color: Colors.white, fontSize: 18),
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
    intervalText = 'every_day_of_week'
        .tr(args: [DateFormat('EEEE').format(DateTime.now())]);
  }
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      buildHeadingText(title: 'Repeat :'.tr()),
      Row(
        children: [
          const Icon(
            Icons.repeat_on,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(
            width: 5.0,
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
    style: const TextStyle(
      color: Colors.white,
      fontSize: 18,
    ),
  );
}
