import 'package:flutter/material.dart';
import 'package:vv/Notes/models/note_model.dart';
import 'package:vv/Notes/views/widgets/Edit_Notes_View_Body.dart';

class Edit_Notes_View extends StatelessWidget {
  const Edit_Notes_View({super.key, required this.note});
  final NoteModel note;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Edit_Notes_View_Body(
        note:note,
      ),
    );
  }
}
