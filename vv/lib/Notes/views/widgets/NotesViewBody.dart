import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vv/Notes/cubits/notes_cubit/notes_cubit.dart';
import 'package:vv/Notes/views/widgets/CustomAppBar.dart';
import 'package:vv/Notes/views/widgets/Notes_List_View.dart';

class NotesViewBody extends StatefulWidget {
  const NotesViewBody({Key? key}) : super(key: key);

  @override
  State<NotesViewBody> createState() => _NotesViewBodyState();
}

class _NotesViewBodyState extends State<NotesViewBody> {
  void initState() {
    BlocProvider.of<NotesCubit>(context).FetchAllNotes();
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
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              children: [
                SizedBox(
                  height: 48,
                ),
                CustomAppBar(
                  title: 'Notes',
                  // Provide an icon here
                ),
                Expanded(child: NotesListView()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
