import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:vv/api/login_api.dart';

class PatientLocationsScreen extends StatefulWidget {
  @override
  _PatientLocationsScreenState createState() => _PatientLocationsScreenState();
}

class _PatientLocationsScreenState extends State<PatientLocationsScreen> {
  late List<dynamic> data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      var response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/GetPatinetLocationsToday');

      setState(() {
        data = response.data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatTime(String timestamp) {
    final DateTime parsedTime = DateTime.parse(timestamp);
    final DateFormat formatter = DateFormat('h:mm a');
    return formatter.format(parsedTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Locations Today'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : data != null && data.isNotEmpty
              ? ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var location = data[index];
                    return ListTile(
                      title: Text('Latitude: ${location['latitude']}'),
                      subtitle: Text('Longitude: ${location['longitude']}'),
                      trailing:
                          Text('Time: ${formatTime(location['timeStamp'])}'),
                    );
                  },
                )
              : Center(
                  child: Text(
                    'patient does not exit outside Max Distance',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
    );
  }
}
