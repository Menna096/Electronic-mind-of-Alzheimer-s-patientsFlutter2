import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart'; // Import easy_localization.dart
import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart'; // Import mainpagecaregiver.dart
import 'package:vv/api/login_api.dart';
import 'package:vv/utils/storage_manage.dart';
import 'package:vv/widgets/background.dart';

class ReportListScreen extends StatefulWidget {
  @override
  _ReportListScreenState createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  bool isLoading = true;
  List<dynamic> reports = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      String? patientId = await SecureStorageManager()
          .getPatientId(); // Fetch patient ID from secure storage
      final response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Caregiver/GetAllReportsForPatinet/$patientId');
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

  Future<void> _deleteReport(String reportId) async {
    try {
      final response = await DioService().dio.delete(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Caregiver/DeleteReport/$reportId');
      if (response.statusCode == 200) {
        print("Report deleted successfully.");
        setState(() {
          reports.removeWhere(
              (report) => report['reportId'] == reportId); // Update UI
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Report deleted successfully'.tr())));
      } else {
        print("Failed to delete report.");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr('Failed to delete report'))));
      }
    } catch (e) {
      print('Error deleting report: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr('Error deleting report:'))));
    }
  }

  Future<void> _confirmDelete(String reportId) async {
    return showDialog(
      context: context,
      barrierDismissible:
          false, // Dialog cannot be dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr('Confirm Delete')),
          content: Text(tr('Are you sure you want to delete this report?')),
          actions: <Widget>[
            TextButton(
              child: Text(tr('Cancel')),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
            TextButton(
              child: Text(tr('Delete')),
              onPressed: () {
                _deleteReport(reportId); // Call delete method
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => mainpagecaregiver()),
            ); // Go back to the previous page
          },
        ),
        title: Text(
          tr("Patient's Reports"),
          style: TextStyle(
            fontFamily: 'LilitaOne',
            fontSize: 23,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50.0),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Background(
                  SingleChildScrollView: null,
                  child: Container(),
                ),
                Container(
                  padding: EdgeInsets.all(24),
                  child: AnimationLimiter(
                    child: ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (BuildContext context, int index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          delay: Duration(milliseconds: 100),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: ReportCard(
                                report: reports[index],
                                onDelete: () =>
                                    _confirmDelete(reports[index]['reportId']),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final dynamic report;
  final VoidCallback onDelete;

  const ReportCard({
    Key? key,
    required this.report,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report['reportContent'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${report['fromDate']}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w100,
                    fontFamily: 'LilitaOne',
                  ),
                ),
                SizedBox(
                    width: 8), // Add a small space between the text and icon
                Icon(
                  Icons.arrow_right,
                  size: 18, // Adjust size as needed
                  color: Colors.grey, // Match the color with the text
                ),
                SizedBox(
                    width: 8), // Add a small space between the icon and text
                Text(
                  '${report['toDate']}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w100,
                    fontFamily: 'LilitaOne',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => onDelete(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    tr('Delete'),
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
