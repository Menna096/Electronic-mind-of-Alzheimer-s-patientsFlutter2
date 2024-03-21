import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DaySelector extends StatefulWidget {
  const DaySelector({Key? key}) : super(key: key);

  @override
  _DaySelectorState createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now().day;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day,
          (index) {
            final day = index + 1;
            final dateTime =
                DateTime(DateTime.now().year, DateTime.now().month, day);
            final dayName = DateFormat.E().format(dateTime).substring(0, 3);
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDay = day;
                });
              },
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(500),
                    child: Container(
                      width: 40,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedDay == day
                            ? Color.fromARGB(85, 33, 149, 243)
                            : Colors.transparent,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            day.toString(),
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
