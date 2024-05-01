import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vv/Notes/cubits/notes_cubit/notes_cubit.dart';
import 'package:vv/Notes/models/note_model.dart';
import 'package:vv/Notes/views/widgets/ColorListView.dart';
import 'package:vv/Notes/views/widgets/CustomAppBar.dart';
import 'package:vv/Notes/views/widgets/Custom_Text_field.dart';
import 'package:vv/map_location_picker.dart';
import 'package:vv/utils/token_manage.dart';

class Edit_Notes_View_Body extends StatefulWidget {
  const Edit_Notes_View_Body({super.key, required this.note});
  final NoteModel note;

  @override
  State<Edit_Notes_View_Body> createState() => _Edit_Notes_View_BodyState();
}

class _Edit_Notes_View_BodyState extends State<Edit_Notes_View_Body> {
  String? title, content;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xffFFFFFF),
            Color(0xff3B5998),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: 50),
            CustomAppBar(
              onPressed: () {
                widget.note.title = title ?? widget.note.title;
                widget.note.subtitle = content ?? widget.note.subtitle;
                widget.note.save();
                BlocProvider.of<NotesCubit>(context).FetchAllNotes();
                Navigator.pop(context);
              },
              title: 'Edit Note',
              icon: Icons.check,
            ),
            SizedBox(height: 50),
            Custom_Text_field(
                onChanged: (value) {
                  title = value;
                },
                hint: widget.note.title),
            SizedBox(height: 16),
            Custom_Text_field(
                onChanged: (value) {
                  content = value;
                },
                hint: widget.note.subtitle,
                maxlines: 5),
            SizedBox(height: 10),
            EditNodeColorList(
              note: widget.note,
            ),
          ],
        ),
      ),
    );
  }
}

class EditNodeColorList extends StatefulWidget {
  final NoteModel note;

  EditNodeColorList({Key? key, required this.note}) : super(key: key);

  @override
  State<EditNodeColorList> createState() => _EditNodeColorListState();
}

class _EditNodeColorListState extends State<EditNodeColorList> {
  List<Color> colors = [
    Color(0xFF7986CB),
    Color(0xFF3F51B5),
    Color(0xFF5C6BC0),
    Color(0xFF303F9F),
    Color(0xFF3F51B5),
    Color(0xFF3949AB),
    Color(0xFF9FA8DA),
    Color(0xFF283593),
  ];
  late int currentindex;

  @override
  void initState() {
    currentindex = colors.indexOf(Color(widget.note.color));
    super.initState();
  }

  Widget build(BuildContext context) {
    return SizedBox(
      height: 38 * 2,
      child: ListView.builder(
        itemCount: colors.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () {
                currentindex = index;
                widget.note.color = colors[index].value;
                setState(() {});
              },
              child: ColorItem(
                color: colors[index],
                isactive: currentindex == index,
              ),
            ),
          );
        },
      ),
    );
  }
}
