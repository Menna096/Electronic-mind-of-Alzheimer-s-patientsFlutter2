import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:vv/Family/Languagefamily/Languagefamily.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Family/update.dart';
import 'package:vv/page/manage_patient.dart';
import 'package:vv/page/paitent_Id.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:vv/widgets/add/get_code.dart';

Widget buildDrawer(BuildContext context) {
  return Drawer(
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
          buildDrawerItem(
            Icons.person_add_alt_1_sharp,
            'Add Patient',
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => update()));
            },
          ),
          buildDrawerItem(
            Icons.language,
            'Language',
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Language()));
            },
          ),
          buildDrawerItem(
            Icons.logout_outlined,
            'Log Out',
            onTap: () {
              TokenManager.deleteToken();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LoginPageAll()));
            },
          ),
        ],
      ),
    ),
  );
}

Widget buildDrawerItem(IconData icon, String title, {Function? onTap}) {
  return ListTile(
    leading: Icon(icon),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 20,
        color: Color(0xFF595858),
      ),
    ),
    onTap: onTap as void Function()?,
  );
}

class buildFamily extends StatefulWidget {
  @override
  _buildFamilyState createState() => _buildFamilyState();
}

class _buildFamilyState extends State<buildFamily> {
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
    return Stack(
      children: [
        Positioned(
          bottom: 510,
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
          top: 256,
          left: 45,
          child: Image.asset(
            'images/picfam.png',
            width: 110,
            height: 110,
          ),
        ),
        Positioned(
          top: 255,
          left: 217,
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AddPatientScreen()),
              );
            },
            child: Container(
              child: Image.asset(
                'images/patcode.png',
                width: 116,
                height: 116,
              ),
            ),
          ),
        ),
        Positioned(
          top: 386,
          left: 219,
          child: Container(
            child: Image.asset(
              'images/placefam.png',
              width: 109,
              height: 110,
            ),
          ),
        ),
        Positioned(
          top: 385,
          left: 46,
          child: Container(
            child: Image.asset(
              'images/appfam.png',
              width: 110,
              height: 110,
            ),
          ),
        ),
      ],
    );
  }
}

Widget buildImageContainer(
    String imagePath, double width, double height, double top, double left) {
  return Positioned(
    top: top,
    left: left,
    child: Container(
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
      ),
    ),
  );
}
