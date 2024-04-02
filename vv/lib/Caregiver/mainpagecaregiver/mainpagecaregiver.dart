import 'package:flutter/material.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Notes/views/Notes_view/Notes_view.dart';
import 'package:vv/page/level_select.dart';


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
                leading: Icon(Icons.manage_accounts_rounded),
                title: Text(
                  'Manage Profile',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF595858),
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
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginPageAll()), // Navigate to loginpageall and remove all routes beneath it
                    (Route<dynamic> route) => false, // Pop all routes except for the new one
                  );
                },
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
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
              top: 195,
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
              top: 195,
              left: 230,
              child: Container(
                child: Image.asset(
                  'images/Medicines.png',
                  width: 110,
                  height: 110,
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
