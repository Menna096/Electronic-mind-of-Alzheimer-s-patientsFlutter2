import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:vv/api/login_api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicines List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MedicinesPage(),
    );
  }
}

class MedicinesPage extends StatefulWidget {
  @override
  _MedicinesPageState createState() => _MedicinesPageState();
}

class _MedicinesPageState extends State<MedicinesPage> {
  List<dynamic> medicines = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchMedicines();
  }

  Future<void> fetchMedicines() async {
    Dio dio = Dio();
    String url =
        'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetAllMedicines';

    try {
      Response response = await DioService().dio.get(url);
      setState(() {
        medicines = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching medicines: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicines List'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    var medicine = medicines[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Medication Name: ${medicine['medication_Name']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text('Dosage: ${medicine['dosage']}'),
                            SizedBox(height: 5),
                            Text('Medicine Type: ${medicine['medcineType']}'),
                            SizedBox(height: 5),
                            Text('Repeater: ${medicine['repeater']}'),
                            SizedBox(height: 5),
                            Text('Start Date: ${medicine['startDate']}'),
                            SizedBox(height: 5),
                            Text('End Date: ${medicine['endDate']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
