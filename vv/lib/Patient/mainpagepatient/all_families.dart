import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vv/Patient/test.dart';
import 'package:vv/api/login_api.dart'; // Ensure this is correctly implemented
import 'package:vv/models/family_data.dart';
import 'package:vv/utils/storage_manage.dart'; // Ensure this is correctly implemented

// State management for location data
class LocationProvider with ChangeNotifier {
  String _locationData = '';
  double? _latitude;
  double? _longitude;

  String get locationData => _locationData;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  void setLocationData(String newData) {
    _locationData = newData;
    parseLocationData(newData);
    notifyListeners(); // Notify all listening widgets to rebuild
  }

  void parseLocationData(String data) {
    // Example JSON response handling: {"latitude": 35.6895, "longitude": 139.6917}
    var locationJson = jsonDecode(data);
    _latitude = locationJson['latitude'];
    _longitude = locationJson['longitude'];
  }
}

// Main Application Widget
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocationProvider(),
      child: MaterialApp(
        home: UnusualFamilyList(),
      ),
    );
  }
}

class UnusualFamilyList extends StatefulWidget {
  @override
  _UnusualFamilyListState createState() => _UnusualFamilyListState();
}

class _UnusualFamilyListState extends State<UnusualFamilyList>
    with TickerProviderStateMixin {
  late Future<List<FamilyMember>> _familyMembers;
  late AnimationController _controller;
  final SecureStorageManager storageManager = SecureStorageManager();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _familyMembers = _fetchFamilyMembers();
    _controller.forward();
  }

  Future<List<FamilyMember>> _fetchFamilyMembers() async {
    try {
      final response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetPatientFamilies');
      return (response.data as List)
          .map((x) => FamilyMember.fromJson(x))
          .toList();
    } catch (e) {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Family Members"),
        actions: <Widget>[
          IconButton(
            icon: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _controller,
            ),
            onPressed: () {
              if (_controller.isCompleted) {
                _controller.reverse();
              } else {
                _controller.forward();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<FamilyMember>>(
        future: _familyMembers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var member = snapshot.data![index];
                return Dismissible(
                  key: Key(member.familyId), // Use familyId for uniqueness
                  onDismissed: (direction) async {
                    // Store familyId when the item is dismissed
                  },
                  child: ListTile(
                    title: Text(
                        '${member.familyName}'), // Displaying familyId with familyName
                    subtitle: Text(member.relationility),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(member.hisImageUrl),
                    ),
                    trailing: IconButton(
                      onPressed: () async {
                        await storageManager.savefamilyId(member.familyId);
                        await getFamilyLocation(context);
                        print('Stored familyId: ${member.familyId}');
                        // Use named route to ensure provider context is maintained
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Builder(builder: (newContext) {
                              return LocationDisplayScreen();
                            }),
                          ),
                        );
                      },
                      icon: Icon(Icons.location_on),
                    ),
                  ),
                );
              },
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Future<void> getFamilyLocation(BuildContext context) async {
    try {
      String? familyId = await storageManager.getfamilyId();
      if (familyId != null) {
        Response response = await DioService().dio.get(
            'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetFamilyLocation/$familyId');
        print('Family location: ${response.data}');
        Provider.of<LocationProvider>(context, listen: false)
            .setLocationData(response.data.toString());
      } else {
        print('Family ID is null');
      }
    } catch (e) {
      print('Error fetching family location: $e');
    }
  }
}
