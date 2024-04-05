import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/api/login_api.dart';
 

class AddPatientScreen extends StatefulWidget {
  @override
  _AddPatientScreenState createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  String patientCode = 'Loading...'; // Initial text

  @override
  void initState() {
    super.initState();
    _fetchPatientCode();
  }

  Future<void> _fetchPatientCode() async {
    try {
      final response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/GetPatientCode');
      if (response.statusCode == 200) {
        var responseData = response.data;
        String code = responseData['code']; // Access the 'code' field
        setState(() {
          patientCode = code; // Update the patientCode with the fetched code
        });
      } else {
        setState(() {
          patientCode = 'You need to add Patient or assign him to you first';
        });
      }
    } catch (e) {
      setState(() {
        patientCode = 'You need to add Patient or assign him to you first';
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300, // Light grey background
      body: Center(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.blue.shade900],
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: 300, // Fixed width for the card
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Add Patient',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Patient ID',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 10.0), // Adjust padding as needed
                      suffixIcon: IconButton(
                        icon: Icon(Icons.copy), // The copy icon
                        onPressed: () {
                          // Copy the current text in the TextField to the clipboard
                          Clipboard.setData(ClipboardData(text: patientCode))
                              .then((_) {
                            // Show a Snackbar or some other indication that the text has been copied
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Patient ID copied to clipboard!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          });
                        },
                      ),
                    ),
                    readOnly: true,
                    controller: TextEditingController(text: patientCode),
                    style:
                        TextStyle(fontSize: 20), // Adjust font size as needed
                    maxLines: null, // Allows for multiple lines
                    keyboardType:
                        TextInputType.multiline, // Allows for line breaks
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Please send it to anyone responsible for the patient',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => mainpagefamily()),
                      );
                    },
                    child: Text('Done'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      fixedSize: Size(150, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
