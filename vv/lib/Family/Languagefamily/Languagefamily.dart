import 'package:flutter/material.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';

class Languagefamily extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff3B5998),
      resizeToAvoidBottomInset: false,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 80),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF526CA4).withOpacity(0.2),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.grey),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => mainpagefamily(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                children: [
                  Image.asset(
                    'images/languageicon.png',
                    height: 50,
                    width: 50,
                  ),
                  SizedBox(width: 1),
                  Text(
                    'Language',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.only(left: 17.0),
              child: Text(
                'Select Your Language',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Handle the action for the first button
                  // You can navigate to another page or perform any other action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0386D0),
                  padding: EdgeInsets.symmetric(horizontal: 39, vertical: 19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27.0),
                  ),
                ),
                child: Text(
                  'English',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff3B5998),
                  ),
                ),
              ),
            ),
            SizedBox(height: 1),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Handle the action for the second button
                  // You can navigate to another page or perform any other action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0386D0),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27.0),
                  ),
                ),
                child: Text(
                  'العربيه',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff3B5998),
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
