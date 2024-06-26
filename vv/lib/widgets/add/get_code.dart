import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:vv/page/assign_patient.dart';
import 'package:vv/page/paitent_Id.dart';

class AddOrGetCode extends StatelessWidget {
  const AddOrGetCode({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:  Text('Patient Code'.tr()), // Title changed as per your request
      actions: <Widget>[
        TextButton(
          child: Text('Get Patient Code'.tr()),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AddPatientScreen()),
            );
            // Navigator.of(context).pop(); // Close the dialog
          },
        ),
        TextButton(
          child:  Text('Assign Patient'.tr()),
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
