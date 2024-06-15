import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:vv/Patient/gpsssss/pages/google_map_page.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:vv/api/login_api.dart'; // Ensure this is correctly implemented
import 'package:vv/map_location_picker.dart';
import 'package:vv/models/family_data.dart';
import 'package:vv/utils/storage_manage.dart';
import 'package:vv/utils/token_manage.dart'; // Ensure this is correctly implemented

class UnusualFamilyList extends StatefulWidget {
  @override
  _UnusualFamilyListState createState() => _UnusualFamilyListState();
}

class _UnusualFamilyListState extends State<UnusualFamilyList>
    with TickerProviderStateMixin {
  late Future<List<FamilyMember>> _familyMembers;
  late AnimationController _controller;
  double _position1 = 0; // Position for the top circle
  double _position2 = 0; // Position for the bottom circle
  final SecureStorageManager storageManager = SecureStorageManager();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // Adjust animation duration
    );

    // Repeat the animation indefinitely
    _controller.repeat();

    _familyMembers = _fetchFamilyMembers();
  }

  Future<List<FamilyMember>> _fetchFamilyMembers() async {
    try {
      final response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetPatientRelatedMembers');
      return (response.data as List)
          .map((x) => FamilyMember.fromJson(x))
          .toList();
    } catch (e) {
      throw Exception('Failed to load data');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff3B5998),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => mainpatient()),
            );
          },
        ),
        title: Text(
          "Family Members",
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
              bottom: Radius.circular(1.0),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Background with animated circular shapes
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    // Calculate positions for the two circles
                    _position1 = _controller.value * 150; 
                    _position2 = _controller.value * 100; // Slower movement

                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color.fromARGB(255, 236, 239, 241),Color.fromARGB(109, 106, 148, 233)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Animated circles
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 500),
                            top: _position1,
                            left: -100,
                            child: CircleAvatar(
                              radius: 200,
                              backgroundColor:
                                  Colors.white.withOpacity(0.1),
                            ),
                          ),
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 700), // Slower movement
                            bottom: -_position2,
                            right: -100,
                            child: CircleAvatar(
                              radius: 200,
                              backgroundColor:
                                  Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: FutureBuilder<List<FamilyMember>>(
                    future: _familyMembers,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return Center(child: Text('No family members found'));
                      } else {
                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var member = snapshot.data![index];
                            return Dismissible(
                              key: Key(member.familyId), // Use familyId for uniqueness
                              onDismissed: (direction) async {
                                // Store familyId when the item is dismissed
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: AlignmentDirectional.centerEnd,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              child: Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(member.hisImageUrl),
                                    radius: 30,
                                  ),
                                  title: Text(
                                    '${member.familyName}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      Text(
                                        member.relationility,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      if (member.familyDescriptionForPatient !=
                                          null)
                                        SizedBox(height: 4),
                                      if (member.familyDescriptionForPatient !=
                                          null)
                                        Text(
                                          member.familyDescriptionForPatient!,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    onPressed: () async {
                                      await storageManager.savefamilyId(
                                          member.familyId);
                                      final familyLocationResponse =
                                          await DioService()
                                              .dio
                                              .get(
                                                  'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetFamilyLocation/${member.familyId}');
                                      final familyLocationData =
                                          familyLocationResponse.data;
                                      final latitude =
                                          familyLocationData['latitude'];
                                      final longitude =
                                          familyLocationData['longitude'];
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              NavigationScreen(
                                                  latitude, longitude),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.location_on,
                                      color: Color(0xFF6A95E9), // Set icon color to blue
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}