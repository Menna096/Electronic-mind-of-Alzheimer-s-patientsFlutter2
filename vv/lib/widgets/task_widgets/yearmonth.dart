import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class CurrentMonthYearWidget extends StatelessWidget {
  const CurrentMonthYearWidget({super.key});

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
          style: const TextStyle(
            fontSize: 30,
          ),
        ),
        const Text(',',
            // ignore: unnecessary_const
            style: const TextStyle(
              fontSize: 30,
            )),
        Text(
          currentYear,
          style: const TextStyle(
            fontSize: 30,
          ),
        ),
      ],
    );
  }
}
