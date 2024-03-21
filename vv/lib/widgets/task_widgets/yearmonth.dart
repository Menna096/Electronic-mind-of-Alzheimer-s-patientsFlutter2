import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class CurrentMonthYearWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current date
    DateTime now = DateTime.now();

    // Format the current month
    String currentMonth = DateFormat('MMM').format(now);

    // Format the current year
    String currentYear = DateFormat('yyyy').format(now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          currentMonth,
          style: TextStyle(
            fontSize: 30,
          ),
        ),
        Text(',',
            style: TextStyle(
              fontSize: 30,
            )),
        Text(
          currentYear,
          style: TextStyle(
            fontSize: 30,
          ),
        ),
      ],
    );
  }
}
