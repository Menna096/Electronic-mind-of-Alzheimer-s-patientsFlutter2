import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import 'package:vv/Caregiver/medical/constants.dart';
import 'package:vv/Caregiver/medical/global_bloc.dart';
import 'package:vv/Caregiver/medical/pages/new_entry/new_entry_page.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/utils/storage_manage.dart';
import 'package:provider/provider.dart';

Future<List<dynamic>> fetchMedicationData() async {
  final SecureStorageManager storageManager = SecureStorageManager();
  String? patientId = await storageManager.getPatientId();
  var response = await DioService().dio.get(
      'https://electronicmindofalzheimerpatients.azurewebsites.net/Caregiver/GetMedicationRemindersForPatient/$patientId');
  if (response.statusCode == 200) {
    return response.data
        as List<dynamic>; // Assuming response.data is already a List
  } else {
    throw Exception('Failed to load medication data');
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _medicationData;

  @override
  void initState() {
    super.initState();
    _medicationData = fetchMedicationData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication', style: TextStyle(fontSize: 25)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFFFFF), Color(0xff3B5998)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(2.h),
          child: Column(
            children: [
              const TopContainer(),
              SizedBox(height: 2.h),
              Flexible(
                child: FutureBuilder<List<dynamic>>(
                  future: _medicationData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text("No Medication Yet👨‍⚕️"));
                    } else {
                      return GridView.builder(
                        padding: EdgeInsets.only(top: 1.h),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return MedicineCard(data: snapshot.data![index]);
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: InkResponse(
        onTap: () {
          // go to new entry page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewEntryPage(),
            ),
          );
        },
        child: SizedBox(
          width: 18.w,
          height: 9.h,
          child: Card(
            color: kPrimaryColor,
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(3.h),
            ),
            child: Icon(
              Icons.medication,
              color: kScaffoldColor,
              size: 30.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class TopContainer extends StatelessWidget {
  const TopContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(
            bottom: 1.h,
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
      ],
    );
  }
}

class BottomContainer extends StatelessWidget {
  const BottomContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);

    return StreamBuilder<List<dynamic>>(
      stream: globalBloc.medicineList$,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(); // No data case
        } else if (snapshot.data!.isEmpty) {
          return Center(
            // Empty list case
            child: Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: 225),
              child: Text(
                'No Medicine Yet👨‍⚕️',
                style: Theme.of(context).textTheme.headline3?.copyWith(
                    color: Colors.white,
                    fontFamily: 'ConcertOne',
                    fontSize: 38),
              ),
            ),
          );
        } else {
          return GridView.builder(
            padding: EdgeInsets.only(top: 1.h),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return MedicineCard(data: snapshot.data![index]);
            },
          );
        }
      },
    );
  }
}

class MedicineCard extends StatelessWidget {
  const MedicineCard({Key? key, required this.data}) : super(key: key);
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    String medicineType =
        data['medcineType'].toString(); // Medicine type as a string
    String medicineName = data['medication_Name']; // Medicine name

    // Widget to display the appropriate icon based on the medicine type
    Widget icon = _makeIcon(medicineType);

    // Return a card with the medicine information
    return Card(
      color: Colors.white, // Background color of the card
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: "$medicineName$medicineType", // Unique tag for Hero animation
            child: icon,
          ),
          Text(
            medicineName,
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(
            'Dosage: ${data['dosage']} mg',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ],
      ),
    );
  }

  // Helper method to determine which icon to use
  Widget _makeIcon(String type) {
    switch (type) {
      case '0': // Pill
        return Image.asset('lib/page/task_screens/assets/icons/pills.gif',
            height: 13.5.h);
      case '1': // Syringe
        return Image.asset('lib/page/task_screens/assets/icons/syringe.gif',
            height: 13.5.h);
      case '2': // Bottle
        return Image.asset('lib/page/task_screens/assets/icons/liquid.gif',
            height: 13.5.h);
      case '3': // Tablet
        return Image.asset('lib/page/task_screens/assets/icons/tablet.gif',
            height: 13.5.h);
      default:
        return Icon(Icons.error,
            size: 24.sp); // Default icon if type is unknown
    }
  }
}