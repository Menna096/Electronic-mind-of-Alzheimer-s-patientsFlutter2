import 'package:vv/Notes/views/widgets/AddNoteBottomSheet.dart';
import 'package:vv/Notes/views/widgets/NotesViewBody.dart';
import 'package:flutter/material.dart';

class Notes_view extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 236, 236, 236).withOpacity(0.9),
        onPressed: () {
          showModalBottomSheet(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              backgroundColor: Color.fromARGB(255, 60, 60, 60).withOpacity(0.8),
              context: context,
              builder: (context) {
                return const AddNoteBottomSheet();
              });
        },
        child: Icon(
          Icons.add,
          color: Color(0xFF2D2D2a),
        ),
      ),
      body: NotesViewBody(),
    );
  }
}
