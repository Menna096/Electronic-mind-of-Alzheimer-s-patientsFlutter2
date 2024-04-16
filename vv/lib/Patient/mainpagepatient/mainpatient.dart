import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:vv/Family/Languagefamily/Languagefamily.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Notes/views/Notes_view/Notes_view.dart';
import 'package:vv/Patient/mainpagepatient/all_families.dart';
import 'package:vv/Patient/mainpagepatient/patient_media.dart';
import 'package:vv/Patient/mainpagepatient/patient_prof.dart';
import 'package:vv/Patient/mainpagepatient/vediooooo/show_sec.dart';
import 'package:vv/daily_task/pages/home/home_page.dart';
import 'package:vv/page/level_select.dart';
import 'package:vv/utils/token_manage.dart';

class mainpatient extends StatefulWidget {
  @override
  State<mainpatient> createState() => _mainpatientState();
}

class _mainpatientState extends State<mainpatient> {
  String? _token;
  String? _photoUrl;
  String? _userName;
  @override
  void initState() {
    super.initState();
    _getDataFromToken();
  }

  Future<void> _getDataFromToken() async {
    _token = await TokenManager.getToken();
    if (_token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
      setState(() {
        _photoUrl = decodedToken['UserAvatar'];
        _userName = decodedToken['FullName'];
      });
    }
  }

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
                  // Navigate to the language page when Language is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PatientProfManage()),
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
              bottom: 570,
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
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 45.0,
                        backgroundImage: NetworkImage(_photoUrl ?? ''),
                      ),
                      SizedBox(width: 16.0),
                      Column(
                        children: [
                          Text(
                            'Welcome $_userName !',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'To the Electronic mind',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'of Alzheimer patient',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UnusualFamilyList()),
                  );
                },
                child: Container(
                  child: Image.asset(
                    'images/Places.png',
                    width: 110,
                    height: 110,
                  ),
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
              top: 530,
              left: 43,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                },
                child: Container(
                  child: Image.asset(
                    'images/dailytasks.png',
                    width: 115,
                    height: 115,
                  ),
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
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => FilePage()),
                  );
                },

              child: Container(
                child: Image.asset(
                  'images/Files.png',
                  width: 110,
                  height: 110,
                ),
              ),
            ),
            ),
            Positioned(
              top: 432,
              left: 230,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GalleryScreenPatient()),
                  );
                },
                child: Container(
                  child: Image.asset(
                    'images/Pictures.png',
                    width: 110,
                    height: 110,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 532,
              left: 233,
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
