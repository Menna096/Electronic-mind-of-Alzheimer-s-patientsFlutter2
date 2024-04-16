import 'package:flutter/material.dart';
import 'package:vv/widgets/language_button.dart';

class Language extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff3B5998),
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
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
            const SizedBox(height: 80),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF526CA4).withOpacity(0.2),
                    ),
                    child: const BackButton(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                children: [
                  Image.asset(
                    'images/languageicon.png',
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(width: 10),
                  const Text(
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
            const SizedBox(height: 70),
            const Padding(
              padding: EdgeInsets.only(left: 17.0),
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
            const SizedBox(height: 70),

            LanguageButton(
              onPressed: () {},
              buttonText: 'English',
            ),
            const SizedBox(height: 10),
            LanguageButton(
              onPressed: () {},
              buttonText: 'العربيه',

            ),
          ],
        ),
      ),
    );
  }
}
