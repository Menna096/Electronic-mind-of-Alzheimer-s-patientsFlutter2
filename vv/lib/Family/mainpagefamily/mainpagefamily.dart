import 'package:flutter/material.dart';
import 'package:vv/widgets/background.dart';
import 'package:vv/widgets/mainfamily.dart';

// ignore: camel_case_types
class mainpagefamily extends StatelessWidget {
  const mainpagefamily({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 84, 134, 235),
      ),
      drawer: buildDrawer(context),
      resizeToAvoidBottomInset: false,
      body: Background(
        SingleChildScrollView: null,
        child: buildFamily(),
      ),
    );
  }
}
