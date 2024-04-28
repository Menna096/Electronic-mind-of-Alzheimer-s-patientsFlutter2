import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<String> getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String address = placemark.street ?? '';
        if (placemark.subLocality != null) {
          address += ', ' + placemark.subLocality!;
        }
        if (placemark.locality != null) {
          address += ', ' + placemark.locality!;
        }
        if (placemark.subAdministrativeArea != null) {
          address += ', ' + placemark.subAdministrativeArea!;
        }
        if (placemark.administrativeArea != null) {
          address += ', ' + placemark.administrativeArea!;
        }
        if (placemark.country != null) {
          address += ', ' + placemark.country!;
        }
        return address;
      } else {
        return 'Address not found';
      }
    } catch (e) {
      print('Error retrieving address: $e');
      return 'Error retrieving address';
    }
  }

  void openMap(double latitude, double longitude) async {
    String url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
                    return FutureBuilder<String>(
                      future: getAddress(
                          location['latitude'], location['longitude']),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          String address = snapshot.data!;
                          return ListTile(
                            title: Text('Address: $address'),
                            subtitle: Text(
                                'Time: ${formatTime(location['timeStamp'])}'),
                            trailing: OutlinedButton(
                              onPressed: () {
                                openMap(location['latitude'],
                                    location['longitude']);
                              },
                              child: Text('View on Map'),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return ListTile(
                            title: Text('Error retrieving address'),
                            subtitle: Text(
                                'Time: ${formatTime(location['timeStamp'])}'),
                            trailing: OutlinedButton(
                              onPressed: () {
                                // Add your button logic here
                                // This function will be called when the button is pressed
                              },
                              child: Text('View on Map'),
                            ),
                          );
                        } else {
                          return ListTile(
                            title: Text('Loading address...'),
                            subtitle: Text(
                                'Time: ${formatTime(location['timeStamp'])}'),
                            trailing: CircularProgressIndicator(),
                          );
                        }
                      },
                    );
                  },
                )
              : Center(child: Text('No data available')),
    );
  }
}

