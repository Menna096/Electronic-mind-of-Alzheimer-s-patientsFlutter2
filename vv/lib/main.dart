
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Notes/cubits/notes_cubit/notes_cubit.dart';
import 'package:vv/Notes/models/note_model.dart';
import 'package:vv/Notes/simple_bloc_observer.dart';
import 'package:vv/home/one.dart';
import 'package:vv/page/home_page.dart';
import 'package:vv/page/task_screens/adddtask.dart';
import 'package:vv/page/task_screens/tasklist.dart';







void main() async {
  await Hive.initFlutter();
  Bloc.observer = SimpleBlocObserver();
  Hive.registerAdapter(NoteModelAdapter());
  await Hive.openBox<NoteModel>('Notes_Box');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotesCubit(),
      child:  MaterialApp(
        home:  Onboarding(showSignInScreen: () {  },),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}








