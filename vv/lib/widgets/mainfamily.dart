// import 'package:flutter/material.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:vv/Family/AddPersonWithoutAccount.dart';
// import 'package:vv/Family/Languagefamily/Languagefamily.dart';
// import 'package:vv/Family/LoginPageAll.dart';
// import 'package:vv/Family/appoint_list.dart';
// import 'package:vv/Family/patientLocToday.dart';
// import 'package:vv/Family/patient_reports.dart';
// import 'package:vv/Family/update.dart';
// import 'package:vv/page/assignPatCare.dart';
// import 'package:vv/page/gallery_screen.dart';
// import 'package:vv/page/paitent_Id.dart';
// import 'package:vv/utils/token_manage.dart';

// class buildFamily extends StatefulWidget {
//   const buildFamily({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _buildFamilyState createState() => _buildFamilyState();
// }

// class _buildFamilyState extends State<buildFamily> {
//   String? _token;
//   String? _photoUrl;
//   String? _userName;

//   @override
//   void initState() {
//     super.initState();
//     _getDataFromToken();
//   }

//   Future<void> _getDataFromToken() async {
//     _token = await TokenManager.getToken();
//     if (_token != null) {
//       Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
//       setState(() {
//         _photoUrl = decodedToken['UserAvatar'];
//         _userName = decodedToken['FullName'];
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xffFFFFFF),
//                   Color(0xff3B5998),
//                 ],
//               ),
//             ),
//           ),
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(16.0),
//                     decoration: const BoxDecoration(
//                       color: Color.fromARGB(150, 33, 149, 243),
//                       borderRadius: BorderRadius.only(
//                         topRight: Radius.circular(50.0),
//                         bottomRight: Radius.circular(50.0),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.max,
//                       children: [
//                         CircleAvatar(
//                           radius: 45.0,
//                           backgroundImage: NetworkImage(_photoUrl ?? ''),
//                         ),
//                         const SizedBox(width: 16.0),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Welcome $_userName!',
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   color: Colors.white,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               const Text(
//                                 'To the Electronic mind',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   color: Colors.white,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               const Text(
//                                 'of Alzheimer patient',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   color: Colors.white,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 32.0),
//                   Expanded(
//                     child: Wrap(
//                       alignment: WrapAlignment.center,
//                       spacing: 40.0,
//                       runSpacing: 40.0,
//                       children: [
//                         _buildIconButton(
//                           context,
//                           'images/picfam.png',
//                            GalleryScreen(),
//                           94,
//                           94,
//                         ),
//                         _buildIconButton(
//                           context,
//                           'images/patcode.png',
//                            AddPatientScreen(),
//                           94,
//                           94,
//                         ),
//                         _buildIconButton(
//                           context,
//                           'images/placefam.png',
//                            PatientLocationsScreen(),
//                           94,
//                           90,
//                         ),
//                         _buildIconButton(
//                           context,
//                           'images/appfam.png',
//                           AppointListScreen(),
//                           96,
//                           90,
//                         ),
//                         _buildIconButton(
//                           context,
//                           'images/asspat.png',
//                           AssignPatientPage(),
//                           99,
//                           94,
//                         ),
//                         _buildIconButton(
//                           context,
//                           'images/Rports.png',
//                           ReportListScreenFamily(),
//                           102,
//                           91.5,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildIconButton(BuildContext context, String assetPath, Widget screen, double width, double height) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => screen),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15.0),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               spreadRadius: 2,
//               blurRadius: 4,
//               offset: const Offset(2, 3),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(8.0),
//         child: Image.asset(
//           assetPath,
//           width: width,
//           height: height,
//         ),
//       ),
//     );
//   }
// }
