// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart';
// import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';

// import 'package:vv/page/addpat.dart';


// class AssignedPatients extends StatefulWidget {
//   @override
//   _AssignedPatientsState createState() => _AssignedPatientsState();
// }

// class _AssignedPatientsState extends State<AssignedPatients> {
//   final TextEditingController _patientCodeController = TextEditingController();
//   final TextEditingController _relationController = TextEditingController();

//   Future<void> _submitPatientRelation() async {
//     try {
//       final response = await Dio().get(
//         'https://electronicmindofalzheimerpatients.azurewebsites.net/Caregiver/GetAssignedPatients',
//       );
//       if (response.statusCode == 200) {
//         // Handle response
//         print("Data received successfully");
//         // Example: Parse the response data
//         // var responseData = response.data;
//       } else {
//         // Handle error
//         print("Failed to get data");
//       }
//     } catch (e) {
//       print("Error getting data: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade300, // Light grey background
//       body: Center(
//         child: Container(
//           width: double.infinity,
//           height: MediaQuery.of(context).size.height,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Colors.transparent, Colors.blue.shade900],
//             ),
//           ),
//           child: Align(
//             alignment: Alignment.center,
//             child: Container(
//               width: 300, // Fixed width for the card
//               padding: EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12.0),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 8.0,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: <Widget>[
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.close_rounded),
//                         tooltip: 'Exit',
//                         onPressed: () {
//                           // Navigate to the target screen when the button is pressed
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => mainpagecaregiver()),
//                           );
//                         },
//                       ),
//                       Text(
//                         'Assign Patient',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 24),
//                   TextField(
//                     decoration: InputDecoration(
//                       labelText: 'Patient Code',
//                       border: OutlineInputBorder(),
//                     ),
//                     controller: _patientCodeController,
//                   ),
//                   SizedBox(height: 24),
//                   TextField(
//                     decoration: InputDecoration(
//                       labelText: 'Relation',
//                       border: OutlineInputBorder(),
//                     ),
//                     controller: _relationController,
//                   ),
//                   SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: _submitPatientRelation,
//                     child: Text(
//                       'Submit',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       fixedSize: Size(150, 50),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30.0),
//                       ),
//                     ),
//                   ),
//                   TextButton(
//                       onPressed: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) =>
//                                   Addpat()), // Ensure this is the correct class name for your Assign Patient Screen
//                         );
//                       },
//                       child: Text('create new patient account'))
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
