import 'package:flutter/material.dart';


class Page2 extends StatelessWidget {
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
              left: 2.0,
              top: 80.0,
              child: Container(
                width: 392.0,
                height: 146.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFD9DAE8),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      "Don't know who you are?",
                      style: TextStyle(
                        fontSize: 45.0,
                        color: Color(0xFF757981),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20.0,
              top: 250.0,
              right: 20.0,
              bottom: 20.0,
              child: Column(
                children: [
                  Text(
                    "If You Don’t Remember Who You are, It Means You Have Alzheimer's Disease. "
                    "That's Why It Would Be Good For You To Use Our App. Choose 'Patient' To Benefit "
                    "From The Features Of Elder Helper App.",
                    style: TextStyle(
                      fontSize: 22.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Divider(
                    color: Colors.white,
                    height: 30,
                    thickness: 4,
                  ),
                  Text(
                    "If You are a Caregiver and Want To Take Care Of Your Patients, Choose 'Caregiver'.",
                    style: TextStyle(
                      fontSize: 22.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Divider(
                    color: Colors.white,
                    height: 30,
                    thickness: 4,
                  ),
                  Text(
                    "If You Have a Patient in Your Family, Choose 'Family'.",
                    style: TextStyle(
                      fontSize: 22.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 55.0,
              left: 20.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(27.0),
                child: Container(
                  width: 150.0,
                  height: 50.0,
                  // child: ElevatedButton(
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => MyHomePage()),
                  //     );
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     primary: const Color.fromARGB(255, 37, 126, 199),
                  //   ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Transform.rotate(
                          angle: 3.14159,
                          child: Icon(Icons.arrow_forward),
                        ),
                        Text("Home Page"),
                      ],
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
