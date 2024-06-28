import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart'; // Import the sizer package
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/Notes/cubits/notes_cubit/notes_cubit.dart';
import 'package:vv/Notes/models/note_model.dart';
import 'package:vv/Notes/simple_bloc_observer.dart';
import 'package:vv/daily_task/pages/home/bloc/home_bloc.dart';
import 'package:vv/daily_task/pages/input/bloc/input_bloc.dart';
import 'package:vv/faceid.dart';
import 'package:vv/home/one.dart';
import 'package:vv/utils/token_manage.dart';

import 'daily_task/pages/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await AndroidAlarmManager.initialize();

  await Hive.initFlutter();
  Bloc.observer = MyBlocObserver();
  Hive.registerAdapter(NoteModelAdapter());
  await Hive.openBox<NoteModel>('Notes_Box');

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      startLocale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      saveLocale: true,
      child: MyApp(),
    ),
  );
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
      child: Sizer(
        // Use Sizer for responsiveness
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.blue,
              ),
              // Other theme configurations
            ),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: FutureBuilder<String?>(
              future: TokenManager
                  .getToken(), // Replace with your storage utility method
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else {
                  final String? token = snapshot.data;
                  if (token != null && token.isNotEmpty) {
                    // Token exists, navigate to CameraScreen
                    return const CameraScreen();
                  } else {
                    // Token does not exist, show Onboarding with sign-in screen
                    return Onboarding(
                      showSignInScreen: () {
                        // Handle sign-in action if needed
                      },
                    );
                  }
                }
              },
            ),

            
          );
        },
      ),
    );
  }
}
