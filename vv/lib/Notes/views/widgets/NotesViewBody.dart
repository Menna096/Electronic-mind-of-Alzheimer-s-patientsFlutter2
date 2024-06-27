import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vv/Notes/cubits/notes_cubit/notes_cubit.dart';
import 'package:vv/Notes/views/widgets/CustomAppBar.dart';
import 'package:vv/Notes/views/widgets/Notes_List_View.dart';
import 'package:vv/Notes/voice/home/pages/home_page.dart';

class NotesViewBody extends StatefulWidget {
  const NotesViewBody({super.key});

  @override
  State<NotesViewBody> createState() => _NotesViewBodyState();
}

class _NotesViewBodyState extends State<NotesViewBody> {
  @override
  void initState() {
    BlocProvider.of<NotesCubit>(context).FetchAllNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
                    "No Notes Yet!".tr(),
                    style: TextStyle(
                      color: Color.fromARGB(255, 227, 226, 226),
                      fontSize: 21,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              children: [
                const SizedBox(
                  height: 48,
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to HomePage when the icon is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  child:  CustomAppBar(
                    title: 'Notes'.tr(),
                    icon: Icons.voice_chat,
                    // Provide an icon here
                  ),
                ),
                const Expanded(child: NotesListView()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
