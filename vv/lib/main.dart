import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sizer/sizer.dart';
import 'package:vv/Caregiver/medical/constants.dart';
import 'package:vv/Caregiver/medical/global_bloc.dart';
import 'package:vv/Caregiver/medical/pages/home_page.dart';
import 'package:vv/Caregiver/medical/pages/new_entry/new_entry_page.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Notes/cubits/notes_cubit/notes_cubit.dart';
import 'package:vv/Notes/models/note_model.dart';
import 'package:vv/Notes/simple_bloc_observer.dart';
import 'package:vv/daily_task/pages/home/bloc/home_bloc.dart';
import 'package:vv/daily_task/pages/input/bloc/input_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';//

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Bloc.observer = SimpleBlocObserver();
  Hive.registerAdapter(NoteModelAdapter());
  await Hive.openBox<NoteModel>('Notes_Box');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  GlobalBloc? globalBloc;

  @override
  Widget build(BuildContext context) {
    globalBloc = GlobalBloc();
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
        builder: (context, _) => Provider<GlobalBloc>.value(
          value: globalBloc!,
          child: Sizer(
            builder: (context, orientation, deviceType) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Pill Reminder',
              theme: ThemeData.dark().copyWith(
                primaryColor: kPrimaryColor,
                scaffoldBackgroundColor: kScaffoldColor,
                appBarTheme: AppBarTheme(
                  toolbarHeight: 7,
                  backgroundColor: kScaffoldColor,
                  elevation: 0,
                  iconTheme: IconThemeData(
                    color: kSecondaryColor,
                    size: 20,
                  ),
                  titleTextStyle: GoogleFonts.mulish(
                    color: kTextColor,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.normal,
                    fontSize: 16,
                  ),
                ),
                textTheme: TextTheme(
                  headline3: TextStyle(
                    fontSize: 28,
                    color: kSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  headline4: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: kTextColor,
                  ),
                  headline5: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: kTextColor,
                  ),
                  headline6: GoogleFonts.poppins(
                    fontSize: 13,
                    color: kTextColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                  subtitle1: GoogleFonts.poppins(
                      fontSize: 15, color: kPrimaryColor),
                  subtitle2: GoogleFonts.poppins(
                      fontSize: 12, color: kTextLightColor),
                  caption: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: kTextLightColor,
                  ),
                  labelMedium: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: kTextColor,
                  ),
                ),
                inputDecorationTheme: const InputDecorationTheme(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: kTextLightColor,
                      width: 0.7,
                    ),
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: kTextLightColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryColor),
                  ),
                ),
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: Color.fromARGB(255, 17, 18, 22),
                  hourMinuteColor: Color.fromARGB(255, 218, 218, 218),
                  hourMinuteTextColor:
                      Color.fromARGB(255, 126, 170, 218),
                  dayPeriodColor: Color.fromARGB(255, 126, 170, 218),
                  dayPeriodTextColor: kScaffoldColor,
                  dialBackgroundColor: Color.fromARGB(255, 126, 170, 218),
                  dialHandColor: kPrimaryColor,
                  dialTextColor: Color.fromARGB(255, 1, 1, 1),
                  entryModeIconColor: kOtherColor,
                  dayPeriodTextStyle: GoogleFonts.aBeeZee(
                    fontSize: 8,
                  ),
                ),
              ),
              home: LoginPageAll(), // Use your home screen here
            ),
          ),
        ),
      ),
    );
  }
}