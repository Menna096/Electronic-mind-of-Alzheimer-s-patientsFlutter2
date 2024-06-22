import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/Family/String_manager.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/models/patient.dart';
import 'package:vv/utils/storage_manage.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:vv/widgets/background.dart';

class PatientListScreen extends StatefulWidget {
  @override
  _PatientListScreenState createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> with SingleTickerProviderStateMixin {
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
                    style: const TextStyle(
                      fontSize: 44,
                      fontFamily: 'Acme',
                      color: Color(0xFF0386D0),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Color.fromARGB(214, 209, 8, 8)),
                title: Text(
                  'Log Out'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF595858),
                  ),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPageAll()),
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 45.0,
                      backgroundImage: NetworkImage(_photoUrl ?? ''),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome {name}!'.tr(namedArgs: {'name': _userName ?? ''}),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'To The Electronic Mind Of Alzheimer Patient!👋🏻'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
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
                              await storageManager.setPatientname(patient.patientName);
                              await storageManager.setPatientId(patient.patientId);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => mainpagecaregiver(),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(85, 33, 103, 225),
                                borderRadius: BorderRadius.circular(16),
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
                                  const Icon(
                                    Icons.person_rounded,
                                    size: 32,
                                    color: Color.fromARGB(255, 216, 229, 248),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    patient.patientName,
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w100,
                                      fontFamily: 'dubai',
                                      color: Colors.white,
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
