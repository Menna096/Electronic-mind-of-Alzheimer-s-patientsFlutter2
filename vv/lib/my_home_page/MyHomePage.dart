import 'package:flutter/material.dart';
import 'package:vv/Caregiver/LoginPagecaregiver/LoginPagecaregiver.dart';
import 'package:vv/dont_know who/page2.dart';
import 'package:vv/Patient/LoginPagepatient/LoginPagepatient.dart';
import 'package:vv/Family/LoginPagefamily/LoginPagefamily.dart';


class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffFFFFFF),
              Color(0xff3B5998),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 110.0,
              right: 10.0,
              child: Image.asset(
                'images/layer-1.png',
                width: 355,
                height: 175.01,
              ),
            ),
            Positioned(
              top: 350.0,
              left: 125.0,
              right: 0.0,
              child: Text(
                'Who are you?',
                style: TextStyle(
                  fontSize: 28.0,
                  fontFamily: 'ProtestRiot',
                ),
              ),
            ),
            Positioned(
              top: 420.0,
              right: 90.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPagecaregiver()),
                  );
                },
                child: Text(
                  'CareGiver',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF0386D0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27.0),
                  ),
                  minimumSize: Size(203.0, 50.0),
                ),
              ),
            ),
            Positioned(
              top: 500.0,
              right: 90.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPagepatient()),
                  );
                },
                child: Text(
                  'Patient',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF0386D0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27.0),
                  ),
                  minimumSize: Size(203.0, 50.0),
                ),
              ),
            ),
            Positioned(
              top: 580.0,
              right: 90.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPagefamily()),
                  );
                },
                child: Text(
                  'Family',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF0386D0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27.0),
                  ),
                  minimumSize: Size(203.0, 50.0),
                ),
              ),
            ),
            Positioned(
              bottom: 55.0,
              left: 20.0,
              right: 20.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Page2()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/think.png',
                      width: 30.0,
                      height: 30.0,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      "Don't know who you are?",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
