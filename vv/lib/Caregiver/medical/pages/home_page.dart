import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart';
import 'package:vv/Caregiver/medical/constants.dart';
import 'package:vv/Caregiver/medical/global_bloc.dart';
import 'package:vv/Caregiver/medical/models/medicine.dart';
import 'package:vv/Caregiver/medical/pages/medicine_details/medicine_details.dart';
import 'package:vv/Caregiver/medical/pages/new_entry/new_entry_page.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/utils/storage_manage.dart';
import 'package:provider/provider.dart';

Future<List<dynamic>> fetchMedicationData() async {
  final SecureStorageManager storageManager = SecureStorageManager();
  String? patientId = await storageManager.getPatientId();

  if (patientId == null) {
    return []; // Return an empty list if there's no patient ID
  }

  try {
    var response = await DioService().dio.get(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/Caregiver/GetMedicationRemindersForPatient/$patientId');

    if (response.statusCode == 200) {
      var data = response.data as List<dynamic>;
      if (data.isNotEmpty) {
        await storageManager.saveReminderId(data[0]['reminderId'].toString());
      }
      return data;
    } else {
      return []; // Return an empty list for any non-200 response
    }
  } catch (e) {
    return []; // Return an empty list in case of any error
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
    _fetchMedicationData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchMedicationData();
  }

  void _fetchMedicationData() {
    setState(() {
      _medicationData = fetchMedicationData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication', style: TextStyle(fontSize: 25)),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => mainpagecaregiver(),
              ),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
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
                    } else if (snapshot.hasError || snapshot.data!.isEmpty) {
                      return BottomContainer();
                    } else {
                      return GridView.builder(
                        padding: EdgeInsets.only(top: 1.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          print(
                              "Medicine Type in GridView: ${snapshot.data![index]['medcineType']}");
                          return MedicineCard(
                            data: snapshot.data![index],
                            onDelete: _fetchMedicationData, // Refresh the list
                          );
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewEntryPage(),
            ),
          ).then((_) {
            // Refresh the data when coming back from the NewEntryPage
            _fetchMedicationData();
          });
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
              var data = snapshot.data![index];
              return MedicineCard(
                data: data,
                onDelete: () {
                  globalBloc.removeMedicine(data);
                },
              );
            },
          );
        }
      },
    );
  }
}

class MedicineCard extends StatelessWidget {
  const MedicineCard({Key? key, required this.data, required this.onDelete})
      : super(key: key);
  final dynamic data;
  final VoidCallback onDelete; // Callback to notify deletion

  @override
  Widget build(BuildContext context) {
    String medicineName = data['medication_Name'] ?? 'Unknown';
    int medicineType = (data['medcineType'] as int?) ?? 0;
    String dosage = data['dosage']?.toString() ?? '0';

    Widget icon = _makeIcon(medicineType);
    print(
        "Rendering with type: $medicineType for $medicineName"); // Debugging print

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MedicineDetails(data: data, onDelete: onDelete),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(tag: "$medicineName$medicineType", child: icon),
            Text(medicineName, style: Theme.of(context).textTheme.headline6),
            Text('Dosage: ${dosage} mg',
                style: Theme.of(context).textTheme.subtitle1),
          ],
        ),
      ),
    );
  }
}

Widget _makeIcon(int type) {
  switch (type) {
    case 0:
      return Image.asset('lib/page/task_screens/assets/icons/pills.gif',
          height: 13.5.h);
    case 1:
      return Image.asset('lib/page/task_screens/assets/icons/syringe.gif',
          height: 13.5.h);
    case 2:
      return Image.asset('lib/page/task_screens/assets/icons/liquid.gif',
          height: 13.5.h);
    case 3:
      return Image.asset('lib/page/task_screens/assets/icons/tablet.gif',
          height: 13.5.h);
    default:
      return Icon(Icons.error, size: 24.sp); // Default icon if type is unknown
  }
}
