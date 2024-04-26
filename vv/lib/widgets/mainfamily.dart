import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/widgets.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:vv/Family/AddPersonWithoutAccount.dart';
import 'package:vv/Family/Languagefamily/Languagefamily.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Family/appoint_list.dart';
import 'package:vv/Family/patient_reports.dart';
import 'package:vv/Family/update.dart';
import 'package:vv/page/assignPatCare.dart';
import 'package:vv/page/gallery_screen.dart';
import 'package:vv/page/paitent_Id.dart';
import 'package:vv/utils/token_manage.dart';


Widget buildDrawer(BuildContext context) {
  return Drawer(
    child: Container(
      color: const Color(0xffD6DCE9),
      child: ListView(
        children: [
          const DrawerHeader(
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
            Icons.person_add_alt_1_sharp,
            'Add Person Without Account',
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => AddPerson()));
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
      style: const TextStyle(
        fontSize: 20,
        color: Color(0xFF595858),
      ),
    ),
    onTap: onTap as void Function()?,
  );
}

// ignore: camel_case_types
class buildFamily extends StatefulWidget {
  const buildFamily({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _buildFamilyState createState() => _buildFamilyState();
}

// ignore: camel_case_types
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
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Color.fromARGB(50, 33, 149, 243),
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
                  const SizedBox(width: 16.0),
                  Column(
                    children: [
                      Text(
                        'Welcome $_userName !',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const Text(
                        'To the Electronic mind',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const Text(
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
          top: 259,
          left: 55,
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GalleryScreen()),
              );
            },
            // ignore: avoid_unnecessary_containers
            child: Container(
              child: Image.asset(
                'images/picfam.png',
                width: 94,
                height: 94,
              ),
            ),
          ),
        ),
        Positioned(
          top: 263,
          left: 225,
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AddPatientScreen()),
              );
            },
            // ignore: avoid_unnecessary_containers
            child: Container(
              child: Image.asset(
                'images/patcode.png',
                width: 94,
                height: 94,
              ),
            ),
          ),
        ),
        Positioned(
          top: 392,
          left: 226,
          // ignore: avoid_unnecessary_containers
          child: Container(
            child: Image.asset(
              'images/placefam.png',
              width: 94,
              height: 90,
            ),
          ),
        ),
        Positioned(
          top: 524,
          left: 226,
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AppointListScreen()),
              );
            },
            // ignore: avoid_unnecessary_containers
            child: Container(
              child: Image.asset(
                'images/appfam.png',
                width: 96,
                height: 90,
              ),
            ),
          ),
        ),
        Positioned(
          top: 389,
          left: 55,
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AssignPatientPage()),
              );
            },
            // ignore: avoid_unnecessary_containers
            child: Container(
              child: Image.asset(
                'images/asspat.png',
                width: 99,
                height: 94,
              ),
            ),
          ),
        ),
        Positioned(
          top: 525,
          left: 56,
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ReportListScreenFamily()),
              );
            },
            // ignore: avoid_unnecessary_containers
            child: Container(
              child: Image.asset(
                'images/Rports.png',
                width: 102,
                height: 91.5,
              ),
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
    // ignore: avoid_unnecessary_containers
    child: Container(
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
      ),
    ),
  );
}
