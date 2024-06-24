import 'package:flutter/material.dart';
import 'package:vv/page/assign_patient.dart';
import 'package:vv/page/paitent_Id.dart';

class AddOrGetCode extends StatelessWidget {
  const AddOrGetCode({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Patient Code'), // Title changed as per your request
      actions: <Widget>[
        TextButton(
          child: const Text('Get Patient Code'),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AddPatientScreen()),
            );
            // Navigator.of(context).pop(); // Close the dialog
          },
        ),
        TextButton(
          child: const Text('Assign Patient'),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const assignPatient()),
            );
          },
        ),
      ],
    );
  }
}
