import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vv/Caregiver/mainpagecaregiver/caregiver_id.dart';
import 'package:vv/Caregiver/mainpagecaregiver/create_report.dart';
import 'package:vv/Caregiver/mainpagecaregiver/patient_allGame.dart';
import 'package:vv/Caregiver/mainpagecaregiver/report_list.dart';
import 'package:vv/Caregiver/medical/main.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Family/String_manager.dart';
import 'package:vv/utils/storage_manage.dart';
import 'package:vv/utils/token_manage.dart';

class mainpagecaregiver extends StatefulWidget {
  const mainpagecaregiver({super.key});

  @override
  State<mainpagecaregiver> createState() => _mainpagecaregiverState();
}

class _mainpagecaregiverState extends State<mainpagecaregiver> {
  String? _patientname;

  @override
  void initState() {
    super.initState();
    _getname();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings'.tr(),
          style: const TextStyle(
            fontFamily: 'LilitaOne',
            fontSize: 23,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A95E9), Color(0xFF38A4C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(10.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(66, 55, 134, 190),
                offset: Offset(0, 10),
                blurRadius: 10.0,
              ),
            ],
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50.0),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xffD6DCE9),
          child: ListView(
            children: [
              DrawerHeader(
                child: Center(
                  child: Text(
                    'Elder Helper'.tr(),
                    style: TextStyle(
                      fontSize:
                          25.sp, // Use Sizer to make the font size responsive
                      fontFamily: 'Acme',
                      color: const Color(0xFF0386D0),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.perm_contact_calendar_rounded,
                  color: const Color.fromARGB(255, 84, 134, 235),
                  size: 24.sp, // Use Sizer for icon size
                ),
                title: Text(
                  'Your Code'.tr(),
                  style: TextStyle(
                    fontSize:
                        20.sp, // Use Sizer to make the font size responsive
                    color: const Color(0xFF595858),
                  ),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const caregiverCode()),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: const Color.fromARGB(214, 209, 8, 8),
                  size: 24.sp, // Use Sizer for icon size
                ),
                title: Text(
                  context.tr(StringManager.LogOut),
                  style: TextStyle(
                    fontSize:
                        20.sp, // Use Sizer to make the font size responsive
                    color: const Color(0xFF595858),
                  ),
                ),
                onTap: () {
                  TokenManager.deleteToken();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginPageAll()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffECEFF5),
              Color(0xff3B5998),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top:
                  40, // Adjust this value to position the container further down
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 24.0),
                  margin: const EdgeInsets.symmetric(
                      horizontal:
                          16.0), // Adjust this value to control the width
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6A95E9),
                        Color.fromARGB(255, 116, 196, 216),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    '${'Patient Name:'.tr()} $_patientname',
                    style: const TextStyle(
                      fontSize: 19,
                      color: Colors.white,
                      fontFamily: 'LilitaOne',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 210.5,
              left: 45,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PatientAllGame()),
                  );
                },
                child: Container(
                  child: Image.asset(
                    'images/history.png'.tr(),
                    width: 115,
                    height: 110,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 210,
              left: 230,
              child: GestureDetector(
                onTap: _showDialog,
                child: Container(
                  child: Image.asset(
                    'images/Report.png'.tr(),
                    width: 110,
                    height: 110,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 355,
              left: 140,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Pills()),
                  );
                },
                child: Container(
                  child: Image.asset(
                    'images/Medicinescare.png'.tr(),
                    width: 111,
                    height: 115,
                  ),
                ),
              ),
            ),
            const Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Row(
            children: [
              const Icon(Icons.report, color: Colors.blueAccent),
              const SizedBox(width: 10),
              Text(
                "Report Options".tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'LilitaOne',
                  color: Color.fromARGB(255, 239, 237, 237),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(color: Colors.blueAccent),
              const SizedBox(height: 10),
              Text(
                "Choose an option below:".tr(),
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                icon: const Icon(Icons.create, color: Colors.white),
                label: Text("Create A New Report".tr()),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _createReport();
                },
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                icon:
                    const Icon(Icons.report_gmailerrorred, color: Colors.white),
                label: Text(" Get Patient's Report".tr()),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _getPatientsReport();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _createReport() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ReportScreen()),
    );
  }

  void _getPatientsReport() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ReportListScreen()),
    );
  }

  Future<void> _getname() async {
    String? patientname = await SecureStorageManager().getPatientname();
    setState(() {
      _patientname = patientname;
    });
  }
}
