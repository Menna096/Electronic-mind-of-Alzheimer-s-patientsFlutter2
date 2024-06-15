import 'package:flutter/material.dart';
import 'package:vv/page/addpat.dart';
import 'package:vv/page/assign_patient.dart';

class assign_add extends StatelessWidget {
  const assign_add({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "You don't have patient yet",
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => assignPatient()),
                );
              },
              child: const Text('assign'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Addpat()),
                );
              },
              child: const Text('add'),
            ),
          ],
        ),
      ),
    );
  }
}
