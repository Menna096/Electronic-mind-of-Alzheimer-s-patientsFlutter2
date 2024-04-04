import 'package:flutter/material.dart';
import 'package:vv/page/assign_patient.dart';
import 'package:vv/page/paitent_Id.dart';

class AddOrGetCode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Patient Code'), // Title changed as per your request
      actions: <Widget>[
        TextButton(
          child: Text('Get Patient Code'),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AddPatientScreen()),
            );
            // Navigator.of(context).pop(); // Close the dialog
          },
        ),
        TextButton(
          child: Text('Assign Patient'),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => assignPatient()),
            );
          },
        ),
      ],
    );
  }
}
