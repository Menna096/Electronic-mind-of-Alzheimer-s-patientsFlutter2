// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:vv/Patient/mainpagepatient/vediooooo/details.dart';
// import 'package:vv/Patient/mainpagepatient/vediooooo/vedio.dart';
// import 'package:vv/api/login_api.dart';

// class SecretFilePage extends StatefulWidget {
//   @override
//   _SecretFilePageState createState() => _SecretFilePageState();
// }

// class _SecretFilePageState extends State<SecretFilePage> {
//   List<dynamic> secretFiles = [];
//   final Dio dio = Dio(); // Create Dio Instance

//   @override
//   void initState() {
//     super.initState();
//     fetchSecretFiles();
//   }

//   fetchSecretFiles() async {
//     try {
//       var response = await DioService().dio.get(
//           'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetSecretFile');
//       if (response.statusCode == 200) {
//         setState(() {
//           secretFiles = response.data['secretFiles'];
//         });
//       } else {
//         // Handle error
//         print(
//             'Failed to load secret files with status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error occurred while fetching data: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Secret Files'),
//       ),
//       body: ListView.builder(
//         itemCount: secretFiles.length,
//         itemBuilder: (context, index) {
//           var file = secretFiles[index];
//           if (!file['needToConfirm']) {
//             return ListTile(
//                 title: Text(file['fileName']),
//                 subtitle: Text(file['file_Description']),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => DetailScreenSecret(
//                         url: file['documentUrl'],
//                         fileType: file['documentExtension'],
//                       ),
//                     ),
//                   );
//                 });
//           } else {
//             return ListTile(
//               title: Text(file['fileName']),
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => VideoCaptureScreen(),
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
