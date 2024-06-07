import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: unnecessary_import
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Notes/cubits/notes_cubit/notes_cubit.dart';
import 'package:vv/Notes/models/note_model.dart';
import 'package:vv/Notes/simple_bloc_observer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vv/daily_task/pages/home/bloc/home_bloc.dart';
import 'package:vv/daily_task/pages/input/bloc/input_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Bloc.observer = SimpleBlocObserver();
  Hive.registerAdapter(NoteModelAdapter());
  await Hive.openBox<NoteModel>('Notes_Box');

  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NotesCubit>(
          create: (context) => NotesCubit(),
        ),
        BlocProvider<InputBloc>(
          create: (context) => InputBloc(),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(
                primarySwatch:
                    Colors.blue), // Adjust this according to your color scheme
            // Other theme configurations
          ),
          home: LoginPageAll(),
        ),
      ),
    );
  }
}
//
