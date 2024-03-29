// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:vv/widgets/bottomSheet.dart'; // Assuming bottomSheet.dart exists in your project's 'vv/widgets' directory

// class Profile extends StatefulWidget {
//   @override
//   _ProfileState createState() => _ProfileState();
// }

// class _ProfileState extends State<Profile> {
//   // Declare _imageFile outside the build method for state management
//   PickedFile? _imageFile;

//   void takePhoto(ImageSource source) async {
//     final ImagePicker _picker = ImagePicker();
//     final pickedFile = await _picker.pickImage(source: source);
//     setState(() {
//       _imageFile = pickedFile;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Stack(
//         children: <Widget>[
//           CircleAvatar(
//             radius: 80.0,
//             backgroundImage: _imageFile != null
//                 ? FileImage(File(_imageFile!.path)) // Use null-safe operator
//                 : AssetImage('images/profile.jpg'),
//           ),
//           Positioned(
//             bottom: 20.0,
//             right: 20.0,
//             child: InkWell(
//               onTap: () {
//                 showModalBottomSheet(
//                   context: context,
//                   builder: (builder) => BottomSheetWidget(),
//                 );
//               },
//               child: Icon(
//                 Icons.camera_alt,
//                 color: Colors.teal,
//                 size: 28.0,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: Scaffold(
//       appBar: AppBar(
//         title: Text('Profile'),
//       ),
//       body: Profile(),
//     ),
//   ));
// }
