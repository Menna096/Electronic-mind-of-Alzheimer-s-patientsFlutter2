import 'package:flutter/material.dart';
import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart';
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
            const SnackBar(content: Text("Report deleted successfully!")));
      } else {
        print("Failed to delete report.");
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Failed to delete report.")));
      }
    } catch (e) {
      print('Error deleting report: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error deleting report: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Reports'),
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        mainpagecaregiver()), // Ensure this is the correct class name for your Assign Patient Screen
              );
            },
            icon: const Icon(Icons.arrow_back)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Background(
              SingleChildScrollView: null,
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(report['reportContent'],
                          style: const TextStyle(fontSize: 18)),
                      subtitle: Text(
                          'From: ${report['fromDate']} To: ${report['toDate']}'),
                      leading: Icon(Icons.edit,
                          color: Theme.of(context).primaryColor),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteReport(report[
                            'reportId']), // Call delete method with reportId
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
