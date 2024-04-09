import 'package:flutter/material.dart';
import 'package:vv/Caregiver/mainpagecaregiver/caregiver_id.dart';
import 'package:vv/Family/Languagefamily/Languagefamily.dart';
import 'package:vv/Family/LoginPageAll.dart';

class mainpagecaregiver extends StatelessWidget {
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
              top: 123,
              left: 45,
              child: Container(
                child: Image.asset(
                  'images/appoinmentcare.png',
                  width: 110,
                  height: 110,
                ),
              ),
            ),
            Positioned(
              top: 120,
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
              top: 300,
              left: 115,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            caregiverCode()), // Ensure this is the correct class name for your Assign Patient Screen
                  );
                },
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
}
