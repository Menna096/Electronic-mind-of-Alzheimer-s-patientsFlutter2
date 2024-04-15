import 'package:flutter/material.dart';
import 'package:vv/Caregiver/mainpagecaregiver/caregiver_id.dart';
import 'package:vv/Caregiver/mainpagecaregiver/create_report.dart';
import 'package:vv/Caregiver/mainpagecaregiver/patient_allGame.dart';
import 'package:vv/Caregiver/mainpagecaregiver/patient_list.dart';
import 'package:vv/Caregiver/mainpagecaregiver/report_list.dart';
import 'package:vv/Family/Languagefamily/Languagefamily.dart';
import 'package:vv/Family/LoginPageAll.dart';

class mainpagecaregiver extends StatefulWidget {
  @override
  State<mainpagecaregiver> createState() => _mainpagecaregiverState();
}

class _mainpagecaregiverState extends State<mainpagecaregiver> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 84, 134, 235),
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xffD6DCE9),
          child: ListView(
            children: [
              DrawerHeader(
                child: Center(
                  child: Text(
                    'Elder Helper',
                    style: TextStyle(
                      fontSize: 44,
                      fontFamily: 'Acme',
                      color: Color(0xFF0386D0),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.language),
                title: Text(
                  'Language',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF595858),
                  ),
                ),
                onTap: () {
                  // Navigate to the language page when Language is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Language()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout_outlined),
                title: Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF595858),
                  ),
                ),
                onTap: () {
                  // Navigate to the login page when Log Out is pressed
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPageAll()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.code),
                title: Text(
                  'Your Code',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF595858),
                  ),
                ),
                onTap: () {
                  // Navigate to the login page when Log Out is pressed
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => caregiverCode()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffECEFF5),
              Color(0xff3B5998),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 600,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(50, 33, 149, 243),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50.0),
                      bottomRight: Radius.circular(50.0),
                    ),
                  ),
                  child: Text('Patient Name:'),
                ),
              ),
            ),
            Positioned(
              top: 180,
              left: 45,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PatientAllGame()), // Ensure this is the correct class name for your Assign Patient Screen
                  );
                },
                child: Container(
                  child: Image.asset(
                    'images/Games (1).png',
                    width: 110,
                    height: 110,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 180,
              left: 230,
              child: Container(
                child: Image.asset(
                  'images/Medicinescare.png',
                  width: 110,
                  height: 110,
                ),
              ),
            ),
            Positioned(
              top: 350,
              left: 140,
              child: GestureDetector(
                onTap: _showDialog,
                child: Container(
                  child: Image.asset(
                    'images/Medicinescare.png',
                    width: 110,
                    height: 110,
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Report Options"),
          content: Text("Choose an option below:"),
          actions: <Widget>[
            TextButton(
              child: Text("Create a Report"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _createReport(); // Call your function to create a report
              },
            ),
            TextButton(
              child: Text("Get Patient's Report"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _getPatientsReport(); // Call your function to fetch the patient's report
              },
            )
          ],
        );
      },
    );
  }

  void _createReport() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ReportScreen()), // Ensure this is the correct class name for your Assign Patient Screen
    );
  }

  void _getPatientsReport() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ReportListScreen()), // Ensure this is the correct class name for your Assign Patient Screen
    );
  }
}
