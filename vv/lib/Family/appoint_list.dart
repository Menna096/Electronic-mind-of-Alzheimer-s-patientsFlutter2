import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vv/Family/appoint_details.dart';
import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/task_widgets/dayselect.dart';
import 'package:vv/widgets/task_widgets/yearmonth.dart';
import '../../models/appoint.dart';
import 'addApoint.dart';

class AppointListScreen extends StatefulWidget {
  @override
  _AppointListScreenState createState() => _AppointListScreenState();
}

class _AppointListScreenState extends State<AppointListScreen> {
  List<Appointment> Appoints = [];
  Appointment? selectedAppoint;
  Color pickedColor = const Color(0xFF0386D0);
  void updateAppoint(Appointment oldAppoint, Appointment newAppoint) {
    setState(() {
      final index = Appoints.indexOf(oldAppoint);
      Appoints[index] = newAppoint;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: AlignmentDirectional.bottomCenter,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xffFFFFFF),
            Color(0xff3B5998),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              elevation: 2, // Adjust the elevation as needed
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(39.0),
                bottomRight: const Radius.circular(39.0),
              ),
              color: const Color.fromRGBO(255, 255, 255, 0.708),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(39.0),
                  bottomRight: Radius.circular(39.0),
                ),
                child: Container(
                  decoration: const BoxDecoration(),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      const Center(
                        child: Text(
                          'Appointments',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                      const backbutton(),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 40,
                          ),
                          const CurrentMonthYearWidget(),
                          const SizedBox(
                            width: 40,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AddAppointmentScreen(
                                              onAppointAdded: addAppoint)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // Set circular border radius
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 30),
                                // Increase vertical padding
                                elevation: 4,
                                backgroundColor:
                                    pickedColor, // Add some elevation
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    'Add ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text('Appointment',
                                      style: TextStyle(color: Colors.white))
                                ],
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: DaySelector(),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                'Appointments',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: Appoints.length,
                itemBuilder: (context, index) {
                  return Container(
                      margin:
                          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(168, 255, 255, 255).withOpacity(
                            0.2), // Set white color with 50% opacity
                        borderRadius:
                            BorderRadius.circular(20.0), // Set circular edges
                      ),
                      child: ListTile(
                        //
                        leading: const Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.white,
                        ),
                        title: Text(Appoints[index].name),
                        subtitle: Text(
                          '${DateTime.now().day}. ${DateFormat('MMM').format(DateTime.now())}. ${DateTime.now().year}',
                        ),
                        trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.delete),
                          color: const Color.fromARGB(255, 63, 63, 63),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppointDetailsScreen(
                                appoint: Appoints[index],
                                onAppointUpdated: (editedAppoint) {
                                  updateAppoint(Appoints[index], editedAppoint);
                                },
                              ),
                            ),
                          );
                        },
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addAppoint(Appointment appoint) {
    setState(() {
      Appoints.add(appoint);
    });
  }
}
