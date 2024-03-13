import 'package:flutter/material.dart';
import 'package:vv/Family/Languagefamily/Languagefamily.dart';
import 'package:vv/Family/LoginPageAll.dart';


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
              Icons.manage_accounts_rounded,
              'Manage Profile',
              // onTap: () {
              //   Navigator.of(context).push(MaterialPageRoute(
              //       builder: (context) => Manageprofilepatient()));
              // },
            ),
            buildDrawerItem(
              Icons.person_add_alt_1_sharp,
              'Add Patient',
              // onTap: () {
              //   Navigator.of(context).push(MaterialPageRoute(
              //       builder: (context) => Manageprofilepatient()));
              // },
            ),
            buildDrawerItem(
              Icons.language,
              'Language',
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => Languagefamily()));
              },
            ),
            buildDrawerItem(
              Icons.logout_outlined,
              'Log Out',
              onTap: () {
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

  Widget buildStack() {
    return Stack(
      children: [
        buildImageContainer('images/welcome2.png', 370, 370, 433, 45),
        buildImageContainer('images/note.png', 134, 134, 135, 45),
        buildImageContainer('images/Places.png', 130, 130, 290, 45),
        buildImageContainer('images/Pictures.png', 130, 130, 440, 45),
        buildImageContainer('images/manageprof.png', 110, 110, 132, 230),
        buildImageContainer('images/Appointments.png', 110, 110, 232, 230),
        buildImageContainer('images/Files.png', 110, 110, 332, 230),
        buildImageContainer('images/Pictures.png', 110, 110, 432, 230),
        buildImageContainer('images/Games (1).png', 110, 110, 532, 230),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(),
          ],
        ),
      ],
    );
  }

  Widget buildImageContainer(
      String imagePath,
       double width, 
       double height, 
       double top, 
       double left
       ) {
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
