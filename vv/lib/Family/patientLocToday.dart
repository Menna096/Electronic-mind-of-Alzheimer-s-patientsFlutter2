import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/api/login_api.dart';

class PatientLocationsScreen extends StatefulWidget {
  const PatientLocationsScreen({super.key});

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
          address += ', ${placemark.subLocality!}';
        }
        if (placemark.locality != null) {
          address += ', ${placemark.locality!}';
        }
        if (placemark.subAdministrativeArea != null) {
          address += ', ${placemark.subAdministrativeArea!}';
        }
        if (placemark.administrativeArea != null) {
          address += ', ${placemark.administrativeArea!}';
        }
        if (placemark.country != null) {
          address += ', ${placemark.country!}';
        }
        return address;
      } else {
        return 'Address not found'.tr();
      }
    } catch (e) {
      print('Error retrieving address: $e');
      return 'Error retrieving address'.tr();
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainPageFamily()),
            );
          },
        ),
        title: Text(
          "Patient Location Today".tr(),
          style: TextStyle(
            fontFamily: 'LilitaOne',
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50.0),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            )
          : data.isNotEmpty
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
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: ListTile(
                              
                              title: Text(
                                address,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                  'time'.tr(args: [formatTime(location['timeStamp'])]),),
                              trailing: IconButton(
                                icon: const Icon(Icons.location_on_sharp, color: Colors.blueAccent),
                                onPressed: () {
                                  openMap(location['latitude'],
                                      location['longitude']);
                                },
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.redAccent.withOpacity(0.2),
                                ),
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.redAccent,
                                  size: 24,
                                ),
                              ),
                              title: const Text('Error retrieving address'),
                              subtitle: Text(
                                  '${'time_label'.tr()}: ${formatTime(location['timeStamp'])}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                                onPressed: () {
                                  openMap(location['latitude'],
                                      location['longitude']);
                                },
                              ),
                            ),
                          );
                        } else {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blueAccent.withOpacity(0.2),
                                ),
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                                  strokeWidth: 3,
                                ),
                              ),
                              title:  Text('Loading address...'.tr()),
                              subtitle: Text(
  '${'time_label'.tr()}: ${formatTime(location['timeStamp'])}'),
                                  
                            ),
                          );
                        }
                      },
                    );
                  },
                )
              : Center(
                  child: Text(
                    'No data available'.tr(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
     
      
    );
  }
}