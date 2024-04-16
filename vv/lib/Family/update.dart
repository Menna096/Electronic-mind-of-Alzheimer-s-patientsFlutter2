import 'package:flutter/material.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/page/addpat.dart';
import 'package:vv/page/manage_patient.dart';

class update extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => mainpagefamily()),
            );
          },
        ),
        backgroundColor: const Color.fromARGB(255, 100, 121, 165),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffECEFF5),
              Color(0xff3B5998),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 1.0),
                child: Text(
                  'Manage Patient Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Addpat()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xff3B5998),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27.0),
                ),
              ),
              child: const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to InputScreen page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewProfile()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xff3B5998),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27.0),
                ),
              ),
              child: const Text(
                'Edit Account',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
