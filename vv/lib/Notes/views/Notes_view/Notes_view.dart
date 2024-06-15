import 'package:vv/Notes/views/widgets/AddNoteBottomSheet.dart';
import 'package:vv/Notes/views/widgets/NotesViewBody.dart';
import 'package:flutter/material.dart';



class Notes_View extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 124, 147, 198).withOpacity(0.9),
        onPressed: () {
          showModalBottomSheet(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              backgroundColor: Color.fromARGB(255, 79, 105, 162),
              context: context,
              builder: (context) {
                return const AddNoteBottomSheet();
              });
        },
        child: Icon(
          Icons.add,
          color: Color.fromARGB(255, 248, 248, 247),
        ),
      ),
      body: NotesViewBody(),
    );
    
  }
}
