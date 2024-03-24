import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vv/Notes/cubits/notes_cubit/notes_cubit.dart';
import 'package:vv/Notes/models/note_model.dart';
import 'package:vv/Notes/views/widgets/ColorListView.dart';
import 'package:vv/Notes/views/widgets/CustomAppBar.dart';
import 'package:vv/Notes/views/widgets/Custom_Text_field.dart';

class Edit_Notes_View_Body extends StatefulWidget {
  const Edit_Notes_View_Body({super.key, required this.note});
  final NoteModel note;

  @override
  State<Edit_Notes_View_Body> createState() => _Edit_Notes_View_BodyState();
}

class _Edit_Notes_View_BodyState extends State<Edit_Notes_View_Body> {
  String? title, content;
  @override
  Widget build(BuildContext context) {
    return Padding(
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
    
    Color(0xffD3D0C5),
    Color(0xff9E898E),
    Color(0xff886B69),
    Color(0xff635757),
    Color(0xff93776A),
    Color(0xffDBD5CA),
    Color(0xffB9AE99),
    Color(0xff5C564B),
    Color(0xff897F6E),
    Color(0xff8F8D81),
    Color(0xff6C5E2F),
    Color(0xff957B5E),
    Color(0xff754D36),
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
