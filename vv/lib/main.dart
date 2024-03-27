
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Notes/cubits/notes_cubit/notes_cubit.dart';

import 'package:vv/Notes/views/Notes_view/Notes_view.dart';




void main() async {
  

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotesCubit(),
      child: MaterialApp(
        home: Notes_view(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}








