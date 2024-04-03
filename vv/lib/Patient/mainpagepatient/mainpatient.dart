import 'package:flutter/material.dart';
import 'package:vv/Family/Languagefamily/Languagefamily.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Notes/views/Notes_view/Notes_view.dart';
import 'package:vv/page/level_select.dart';
import 'package:vv/utils/token_manage.dart';

class mainpatient extends StatelessWidget {
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
                  TokenManager.deleteToken();
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
              top: 332,
              left: 45,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Notes_View()),
                  );
                },
                child: Container(
                  child: Image.asset(
                    'images/Notes.png',
                    width: 110,
                    height: 110,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 232,
              left: 45,
              child: Container(
                child: Image.asset(
                  'images/Places.png',
                  width: 110,
                  height: 110,
                ),
              ),
            ),
            Positioned(
              top: 432,
              left: 45,
              child: Container(
                child: Image.asset(
                  'images/Persons.png',
                  width: 110,
                  height: 110,
                ),
              ),
            ),
            Positioned(
              top: 132,
              left: 45,
              child: Container(
                child: Image.asset(
                  'images/appoinmentpat.png',
                  width: 110,
                  height: 110,
                ),
              ),
            ),
            Positioned(
              top: 132,
              left: 230,
              child: Container(
                child: Image.asset(
                  'images/Medicines.png',
                  width: 110,
                  height: 110,
                ),
              ),
            ),
            Positioned(
              top: 232,
              left: 230,
              child: Container(
                child: Image.asset(
                  'images/Chatbot.png',
                  width: 110,
                  height: 110,
                ),
              ),
            ),
            Positioned(
              top: 332,
              left: 230,
              child: Container(
                child: Image.asset(
                  'images/Files.png',
                  width: 110,
                  height: 110,
                ),
              ),
            ),
            Positioned(
              top: 432,
              left: 230,
              child: Container(
                child: Image.asset(
                  'images/Pictures.png',
                  width: 110,
                  height: 110,
                ),
              ),
            ),
            Positioned(
              top: 532,
              left: 135,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => LevelSelectionScreen()));
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
          ],
        ),
      ),
    );
  }
}
