import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vv/api/login_api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FilePage(),
    );
  }
}

class FilePage extends StatefulWidget {
  @override
  _FilePageState createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  late Dio dio;
  bool isLoading = true;
  List<dynamic> dataa = [];

  @override
  void initState() {
    super.initState();
    dio = Dio();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final token =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI2YWFkYzQ0Ny0zM2Q0LTRmODItOTk3Mi1jNzAwYzNkOGU2NGIiLCJlbWFpbCI6InBhdGllbnQyMjk5MDBAZ21haWwuY29tIiwiRnVsbE5hbWUiOiJtZW5uYSIsIlBob25lTnVtYmVyIjoiMzM1NDMzMiIsInVpZCI6IjZmYmE4ZDg4LTk4ODAtNGZlMC1hODAwLWU5NjIyMDY1ZWNiOSIsIlVzZXJBdmF0YXIiOiJodHRwczovL2VsZWN0cm9uaWNtaW5kb2ZhbHpoZWltZXJwYXRpZW50cy5henVyZXdlYnNpdGVzLm5ldC9Vc2VyIEF2YXRhci82ZmJhOGQ4OC05ODgwLTRmZTAtYTgwMC1lOTYyMjA2NWVjYjlfNTQ0YTdhNTUtOTQ4Yi00MGVjLTkxMjMtODMxMWI0OTU3NTdiLmpwZyIsInJvbGVzIjoiUGF0aWVudCIsImV4cCI6MTcyMTAxNTEwNCwiaXNzIjoiQXJ0T2ZDb2RpbmciLCJhdWQiOiJBbHpoZWltYXJBcHAifQ.0b_MxqQnpJaSBi9QgHZX9RCx0IVRb0YYwA4kg-vIGN8';

      final response = await DioService().dio.get(
            'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetSecretFile',
            // options: Options(headers: {'Authorization': 'Bearer $token'}),
          );

      setState(() {
        if (response.data != null) {
          dataa = List.from(response.data[
              'secretFiles']); // Adjust 'files' to the actual key in your response
        } else {
          // Handle null response or missing 'files' key
          dataa = [];
        }
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
        title: Text('File Data'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : dataa.isEmpty
              ? Center(child: Text('No data available'))
              : ListView.builder(
                  itemCount: dataa.length,
                  itemBuilder: (context, index) {
                    // Create variables for easier access
                    String fileName = dataa[index]['fileName'];
                    String fileDescription = dataa[index]
                        ['file_Description']; // Note the key change here
                    String documentUrl = dataa[index]['documentUrl'];

                    return Card(
                      child: ListTile(
                        title: Text(fileName),
                        subtitle: Text(fileDescription),
                        trailing: IconButton(
                          icon: Icon(Icons.link),
                          onPressed: () {
                            _launchURL(
                                documentUrl); // Using a function to handle URL launching
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }

// Function to open a URL
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}