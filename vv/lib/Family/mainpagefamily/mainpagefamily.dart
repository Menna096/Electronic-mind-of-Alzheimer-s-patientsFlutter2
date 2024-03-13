import 'package:flutter/material.dart';
import 'package:vv/Family/Languagefamily/Languagefamily.dart';
import 'package:vv/Family/background.dart';



class mainpagefamily extends StatelessWidget {
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
                )),
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
                // onTap: () {
                //   Navigator.of(context).push(MaterialPageRoute(
                //       builder: (context) => Manageprofilepatient()));
                // },
              ),
               ListTile(
                leading: Icon(Icons.person_add_alt_1_sharp),
                title: Text(
                  'Add Patient',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF595858),
                  ),
                ),
                // onTap: () {
                //   Navigator.of(context).push(MaterialPageRoute(
                //       builder: (context) => Manageprofilepatient()));
                // },
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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Languagefamily()));
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
                // onTap: () {
                //   Navigator.of(context).push(
                //       MaterialPageRoute(builder: (context) => MyHomePage()));
                // },
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Background(
        child: Stack(
          children: [
            Positioned(
              bottom: 433,
              child: Container(
                child: Image.asset(
                  'images/welcome2.png',
                  width: 370,
                  height: 370,
                ),
              ),
            ),
            Positioned(
              top: 135,
              left: 45,
              child: Container(
                child: Image.asset(
                  'images/note.png',
                  width: 134,
                  height: 134,
                ),
              ),
            ),
            Positioned(
              top: 290,
              left: 45,
              child: Container(
                child: Image.asset(
                  'images/Places.png',
                  width: 130,
                  height: 130,
                ),
              ),
            ),
            Positioned(
              top: 440,
              left: 45,
              child: Container(
                child: Image.asset(
                  'images/Pictures.png',
                  width: 130,
                  height: 130,
                ),
              ),
            ),
            Positioned(
              top: 132,
              left: 230,
              child: Container(
                child: Image.asset(
                  'images/manageprof.png',
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
                  'images/Appointments.png',
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
              left: 230,
              child: Container(
                child: Image.asset(
                  'images/Games (1).png',
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