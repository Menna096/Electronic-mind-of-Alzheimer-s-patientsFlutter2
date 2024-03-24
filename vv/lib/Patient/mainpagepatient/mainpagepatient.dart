import 'package:flutter/material.dart';
import 'package:vv/Notes/views/Notes_view/Notes_view.dart';

class ManageProfilePatient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Profile'),
      ),
      body: Center(
        child: Text('This is the Manage Profile page'),
      ),
    );
  }
}

class LanguagePatient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Language'),
      ),
      body: Center(
        child: Text('This is the Language page'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Text('This is the Home page'),
      ),
    );
  }
}

class MainPagePatient extends StatelessWidget {
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
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ManageProfilePatient(),
                    ),
                  );
                },
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LanguagePatient(),
                    ),
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(),
                    ),
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
              bottom: 433,
              child: Container(
                child: Image.asset(
                  'images/welcome2.png',
                  width: 355,
                  height: 355,
                ),
              ),
            ),
            Positioned(
              top: 132,
              left: 45,
              child: GestureDetector(
                onTap: () {
                  // Navigate to the desired page when Notes icon is pressed
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>  Notes_view(),
                    ),
                  );
                },
                child: Container(
                  child: Image.asset(
                    'images/note.png',
                    width: 110,
                    height: 110,
                  ),
                ),
              ),
            ),
            // Other Positioned widgets for other icons...
          ],
        ),
      ),
    );
  }
}

class YourNotesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Notes'),
      ),
      body: Center(
        child: Text('This is the Your Notes page'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MainPagePatient(),
  ));
}
