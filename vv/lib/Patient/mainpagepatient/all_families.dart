import 'package:flutter/material.dart';
import 'package:vv/api/login_api.dart'; // Ensure this is correctly implemented
import 'package:vv/models/family_data.dart'; // Ensure this is correctly implemented

// ignore: use_key_in_widget_constructors
class UnusualFamilyList extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _UnusualFamilyListState createState() => _UnusualFamilyListState();
}

class _UnusualFamilyListState extends State<UnusualFamilyList>
    with TickerProviderStateMixin {
  late Future<List<FamilyMember>> _familyMembers;
  late AnimationController _controller;

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
                  key: Key(member
                      .familyId), // Changed to use familyId for uniqueness
                  onDismissed: (direction) {
                    // Add custom logic on dismiss if needed
                  },
                  child: ListTile(
                    title: Text(
                        '${member.familyName} (${member.familyId})'), // Displaying familyId with familyName
                    subtitle: Text(member.relationility),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(member.hisImageUrl),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
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
}
