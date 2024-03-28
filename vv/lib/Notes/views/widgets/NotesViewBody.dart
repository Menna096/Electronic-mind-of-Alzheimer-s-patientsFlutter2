import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vv/Notes/cubits/notes_cubit/notes_cubit.dart';
import 'package:vv/Notes/views/widgets/CustomAppBar.dart';
import 'package:vv/Notes/views/widgets/Notes_List_View.dart';
import 'package:vv/Notes/voice/home/pages/home_page.dart';

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
          Positioned(
            top: 202.5,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Image.asset(
                    'images/noteees.jpg',
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                  Text(
                    "No Notes Yet!",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 227, 226, 226),
                      fontSize: 21,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              children: [
                SizedBox(
                  height: 48,
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to HomePage when the icon is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  child: CustomAppBar(
                    title: 'Notes',
                    icon: Icons.voice_chat,
                    // Provide an icon here
                  ),
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
