import 'package:flutter/material.dart';
import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/utils/storage_manage.dart';
import 'package:vv/widgets/background.dart';

class ReportListScreenFamily extends StatefulWidget {
  @override
  _ReportListScreenFamilyState createState() => _ReportListScreenFamilyState();
}

class _ReportListScreenFamilyState extends State<ReportListScreenFamily> {
  bool isLoading = true;
  List<dynamic> reports = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      // Fetch patient ID from secure storage
      final response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/GetPatientReports');
      setState(() {
        reports = response.data; // assuming response.data is List<dynamic>
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        print('Failed to fetch reports: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Reports'),
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        mainpagefamily()), // Ensure this is the correct class name for your Assign Patient Screen
              );
            },
            icon: Icon(Icons.arrow_back)),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Background(
              SingleChildScrollView: null,
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(report['reportContent'],
                          style: TextStyle(fontSize: 18)),
                      subtitle: Text(
                          'From: ${report['fromDate']} To: ${report['toDate']}'),
                      leading: Icon(Icons.edit,
                          color: Theme.of(context).primaryColor),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
