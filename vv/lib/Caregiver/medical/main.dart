import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vv/Caregiver/medical/constants.dart';
import 'package:vv/Caregiver/medical/global_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'pages/home_page.dart';

void main() {
  runApp(const Pills());
}

class Pills extends StatefulWidget {
  const Pills({super.key});

  @override
  State<Pills> createState() => _PillsState();
}

class _PillsState extends State<Pills> {
  // This widget is the root of your application.
  GlobalBloc? globalBloc;

  @override
  void initState() {
    globalBloc = GlobalBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<GlobalBloc>.value(
      value: globalBloc!,
      child: Sizer(builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Pill Reminder',
          //theme customization
          theme: ThemeData.dark().copyWith(
            primaryColor: kPrimaryColor,
            scaffoldBackgroundColor: kScaffoldColor,
            //appbar theme
            appBarTheme: AppBarTheme(
              toolbarHeight: 7.h,
              backgroundColor: kScaffoldColor,
              elevation: 0,
              iconTheme: IconThemeData(
                color: kSecondaryColor,
                size: 20.sp,
              ),
              titleTextStyle: GoogleFonts.mulish(
                color: kTextColor,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.normal,
                fontSize: 16.sp,
              ),
            ),
            textTheme: TextTheme(
              headline3: TextStyle(
                fontSize: 28.sp,
                color: kSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
              headline4: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: kTextColor,
              ),
              headline5: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: kTextColor,
              ),
              headline6: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: kTextColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
              subtitle1:
                  GoogleFonts.poppins(fontSize: 15.sp, color: kPrimaryColor),
              subtitle2:
                  GoogleFonts.poppins(fontSize: 12.sp, color: kTextLightColor),
              caption: GoogleFonts.poppins(
                fontSize: 9.sp,
                fontWeight: FontWeight.w400,
                color: kTextLightColor,
              ),
              labelMedium: TextStyle(
                fontSize: 10.sp,
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
            //lets customize the timePicker theme
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Color.fromARGB(255, 17, 18, 22),
              hourMinuteColor:
                  Color.fromARGB(255, 218, 218, 218), //////////////
              hourMinuteTextColor: Color.fromARGB(255, 126, 170, 218),
              dayPeriodColor:
                  Color.fromARGB(255, 126, 170, 218), //////////////,
              dayPeriodTextColor: kScaffoldColor,
              dialBackgroundColor: Color.fromARGB(255, 126, 170, 218),
              dialHandColor: kPrimaryColor,
              dialTextColor: Color.fromARGB(255, 1, 1, 1),
              entryModeIconColor: kOtherColor,
              dayPeriodTextStyle: GoogleFonts.aBeeZee(
                fontSize: 8.sp,
              ),
            ),
          ),
          home: const HomePage(),
        );
      }),
    );
  }
}
