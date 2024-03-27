import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vv/Notes/models/note_model.dart';
import 'package:vv/Notes/simple_bloc_observer.dart';
import 'package:vv/Notes/views/Notes_view/Notes_view.dart';
import 'package:vv/Notes/voice/home/pages/home_page.dart';


class MainNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffFFFFFF),
              Color(0xff3B5998),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                'Welcome to Notes',
                style: TextStyle(
                  fontSize: 40,
                  fontFamily: 'Acme',
                  fontWeight: FontWeight.bold,
                  color: Color(0xff3B5998),
                ),
              ),
            ),
            Image.asset(
              'images/noteees.jpg', // Assuming the image is in the assets folder
              width: 200, // Adjust the width as needed
              height: 200, // Adjust the height as needed
            ),
            SizedBox(height: 20), // Adding space between text and image
            ElevatedButton(
              onPressed: () {
                // Navigate to NotesView when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Notes_view()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 130), // Adjust the padding as needed
              ),
              child: Text('Write Notes'),
            ),
            SizedBox(height: 30), // Adding space between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 118), // Adjust the padding as needed
              ),
              child: Text('Recording Notes'),
            ),
          ],
        ),
      ),
    );
  }
}



void main() async{
  await Hive.initFlutter();
  Bloc.observer = SimpleBlocObserver();
  Hive.registerAdapter(NoteModelAdapter());
  await Hive.openBox<NoteModel>('Notes_Box');
  runApp(MaterialApp(
    home: MainNotes(),
  ));
}
