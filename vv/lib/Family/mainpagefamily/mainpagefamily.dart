import 'package:flutter/material.dart';
import 'package:vv/widgets/background.dart';
import 'package:vv/widgets/mainfamily.dart';

class mainpagefamily extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 84, 134, 235),
      ),
      drawer: buildDrawer(context),
      resizeToAvoidBottomInset: false,
      body: Background(
        child: buildStack(),
      ),
    );
  }
}
