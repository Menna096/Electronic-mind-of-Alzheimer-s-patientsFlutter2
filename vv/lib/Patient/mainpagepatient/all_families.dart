import 'package:flutter/material.dart';
import 'package:vv/Patient/gpsssss/pages/google_map_page.dart';
import 'package:vv/api/login_api.dart'; // Ensure this is correctly implemented
import 'package:vv/models/family_data.dart';
import 'package:vv/utils/storage_manage.dart'; // Ensure this is correctly implemented

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
                        '${member.familyName} '), // Displaying familyId with familyName
                    subtitle: Text(member.relationility),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(member.hisImageUrl),
                    ),
                    trailing: IconButton(
                      onPressed: () async {
                        await storageManager.savefamilyId(member.familyId);
                        final familyLocationResponse = await DioService().dio.get(
                          'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetFamilyLocation/${member.familyId}'
                        );
                        final familyLocationData = familyLocationResponse.data;
                        final latitude = familyLocationData['latitude'];
                        final longitude = familyLocationData['longitude'];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NavigationScreen(latitude, longitude),
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
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
