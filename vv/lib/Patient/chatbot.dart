import 'package:flutter/material.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:vv/faceid.dart';

class OldChatScreen extends StatefulWidget {
  @override
  _OldChatScreenState createState() => _OldChatScreenState();
}

class _OldChatScreenState extends State<OldChatScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make the app bar transparent
        elevation: 0, // Remove the shadow/elevation
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Add the back arrow icon
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const mainpatient(), // Navigate to mainpatient page
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white, // Set the background color to white
        child: Stack(
          children: <Widget>[
            AnimatedBackground(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundImage: AssetImage('images/robot.png'),
                          ),
                          title: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(201, 255, 255, 255),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Welcome to chatbot how can I help you',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      color: Colors.white,
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Type message here...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.mic),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
