import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sizer/sizer.dart';
import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Family/String_manager.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/models/patient.dart';
import 'package:vv/utils/storage_manage.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:vv/widgets/background.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  _PatientListScreenState createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen>
    with SingleTickerProviderStateMixin {
  List<Patient> patients = [];
  bool isLoading = true;
  final SecureStorageManager storageManager = SecureStorageManager();
  String? _token;
  String? _photoUrl;
  String? _userName;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn)
      ..addListener(() {
        setState(() {});
      });

    fetchPatientsFromDatabase();
    _getDataFromToken();

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getDataFromToken() async {
    _token = await TokenManager.getToken();
    if (_token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
      setState(() {
        _photoUrl = decodedToken['UserAvatar'];
        _userName = decodedToken['FullName'];
      });
    }
  }

  Future<void> fetchPatientsFromDatabase() async {
    try {
      final response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Caregiver/GetAssignedPatients');
      final List<dynamic> patientJsonList = response.data;

      final fetchedPatients = patientJsonList
          .map((patientJson) => Patient.fromJson(patientJson))
          .toList();

      setState(() {
        patients = fetchedPatients;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e); // Handle or log error appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xffD6DCE9),
          child: ListView(
            children: [
              DrawerHeader(
                child: Center(
                  child: Text(
                    StringManager.elderHelper.tr(),
                    style: TextStyle(
                      fontSize: SizerUtil.deviceType == DeviceType.mobile
                          ? 8.0.w
                          : 44.0,
                      fontFamily: 'Acme',
                      color: const Color(0xFF0386D0),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: const Color.fromARGB(214, 209, 8, 8),
                  size: SizerUtil.deviceType == DeviceType.mobile ? 5.w : 3.h,
                ),
                title: Text(
                  'Log Out'.tr(),
                  style: TextStyle(
                    fontSize: SizerUtil.deviceType == DeviceType.mobile
                        ? 12.sp
                        : 16.sp,
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
      body: Background(
        SingleChildScrollView: null,
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal:
                        5.w), // Adjust horizontal padding based on screen width
                child: Row(
                  children: [
                    CircleAvatar(
                      radius:
                          12.w, // Adjust avatar radius based on screen width
                      backgroundImage: NetworkImage(_photoUrl ?? ''),
                    ),
                    SizedBox(
                        width: 3
                            .w), // Adjust width of SizedBox based on screen width
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome {name}!'
                                .tr(namedArgs: {'name': _userName ?? ''}),
                            style: TextStyle(
                              fontSize: 1.5
                                  .h, // Adjust font size based on screen height
                            ),
                          ),
                          SizedBox(
                              height: 1
                                  .h), // Adjust height of SizedBox based on screen height
                          Text(
                            'To The Electronic Mind Of Alzheimer Patient!👋🏻'
                                .tr(),
                            style: TextStyle(
                              fontSize: 1.5
                                  .h, // Adjust font size based on screen height
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator()
                  : Flexible(
                      child: ListView.builder(
                        itemCount: patients.length,
                        itemBuilder: (context, index) {
                          final patient = patients[index];
                          return GestureDetector(
                            onTap: () async {
                              await storageManager
                                  .setPatientname(patient.patientName);
                              await storageManager
                                  .setPatientId(patient.patientId);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const mainpagecaregiver(),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 5
                                      .w), // Adjust margins based on screen dimensions
                              padding: EdgeInsets.all(
                                  2.h), // Adjust padding based on screen height
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(85, 33, 103, 225),
                                borderRadius: BorderRadius.circular(16
                                    .sp), // Adjust borderRadius based on screen resolution
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_rounded,
                                    size: 8
                                        .w, // Adjust icon size based on screen width
                                    color: const Color.fromARGB(
                                        255, 216, 229, 248),
                                  ),
                                  SizedBox(
                                      width: 3
                                          .w), // Adjust width of SizedBox based on screen width
                                  Expanded(
                                    child: Text(
                                      patient.patientName,
                                      style: TextStyle(
                                        fontSize: 12
                                            .sp, // Adjust font size based on screen width
                                        fontWeight: FontWeight.w100,
                                        fontFamily: 'dubai',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
