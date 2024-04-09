// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:intl/intl.dart';
// import 'package:vv/Caregiver/mainpagecaregiver/mainpagecaregiver.dart';
// import 'package:vv/api/login_api.dart';
// import 'package:vv/widgets/backbutton.dart';
// import 'package:vv/widgets/custom_Textfield.dart';

// class APIService {
//   static final Dio _dio = Dio();

//   static Future<dynamic> addMedicationReminder({
//     required String patientCode,
//     required String medicationName,
//     required String dosage,
//     required String repeater,
//     required String timePeriod,
//     required DateTime startDate,
//   }) async {
//     try {
      
//       String url = 'https://electronicmindofalzheimerpatients.azurewebsites.net/Caregiver/AddMedicationReminder';
      
//       FormData formData = FormData.fromMap({
//         'patientCode': patientCode,
//         'medicationName': medicationName,
//         'dosage': dosage,
//         'repeater': repeater,
//         'timePeriod': timePeriod,
//         'start date': DateFormat('yyyy-MM-dd').format(startDate),
//       });

//       DioService().dio.options.headers['accept'] = '/';
//       DioService().dio.options.headers['content-type'] = 'multipart/form-data';

//       Response response =await await _dio.post(
//         url,
        
//         data: formData,
//       );

//       return response.statusCode == 200 ? true : response.data != null && response.data['message'] != null ? response.data['message'] : 'Add failed with status code: ${response.data}';
//     } catch (error) {
//       print('Add failed: $error');
//       return 'Add failed: $error';
//     }
//   }
// }

// class med extends StatefulWidget {
//   @override
//   _medState createState() => _medState();
// }

// class _medState extends State<med> {
//   TextEditingController _patientCodeController = TextEditingController();
//   TextEditingController _medicationNameController = TextEditingController();
//   TextEditingController _dosageController = TextEditingController();
//   TextEditingController _repeaterController = TextEditingController();
//   TextEditingController _timePeriodController = TextEditingController();
//   DateTime? selectedDate;

//   void presentDatePicker() {
//     showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     ).then((pickedDate) {
//       if (pickedDate != null) {
//         setState(() {
//           selectedDate = pickedDate;
//         });
//       }
//     });
//   }

//   bool _isLoading = false;

//   void _addMedicationReminder() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       if (_patientCodeController.text.isEmpty ||
//           _medicationNameController.text.isEmpty ||
//           _dosageController.text.isEmpty ||
//           _repeaterController.text.isEmpty ||
//           _timePeriodController.text.isEmpty ||
//           selectedDate == null) {
//         throw 'Please fill in all fields and select a start date.';
//       }

//       dynamic response = await APIService.addMedicationReminder(
//         patientCode: _patientCodeController.text,
//         medicationName: _medicationNameController.text,
//         dosage: _dosageController.text,
//         repeater: _repeaterController.text,
//         timePeriod: _timePeriodController.text,
//         startDate: selectedDate!,
//       );

//       if (response == true) {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text('Add Successful'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => mainpagecaregiver()),
//                   );
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           ),
//         );
//       } else {
//         throw 'Add failed. Please try again. Error: $response';
//       }
//     } catch (error) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Add Failed'),
//           content: Text(error.toString()),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xff3B5998),
//       resizeToAvoidBottomInset: false,
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Color(0xffFFFFFF), Color(0xff3B5998)],
//               ),
//             ),
//             padding: EdgeInsets.all(16.0),
//             child: SingleChildScrollView(
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     backbutton(),
//                     SizedBox(height: 0.5),
//                     Text(
//                       'Add Account',
//                       style: TextStyle(fontSize: 40, fontFamily: 'Acme'),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 18),
//                     CustomTextField(
//                       labelText: '  patientCode',
//                       controller: _patientCodeController,
//                       suffixIcon: Icons.person_2_sharp,
//                     ),
//                     SizedBox(height: 15),
//                     CustomTextField(
//                       labelText: '  dosage',
//                       controller: _dosageController,
//                       suffixIcon: Icons.email_outlined,
//                     ),
//                     SizedBox(height: 15),
//                     CustomTextField(
//                       labelText: '  medication Name',
//                       controller: _medicationNameController,
//                       suffixIcon: Icons.password_outlined,
//                     ),
//                     SizedBox(height: 15),
//                     CustomTextField(
//                       labelText: '  repeater',
//                       suffixIcon: Icons.password_outlined,
//                       controller: _repeaterController,
//                     ),
//                     SizedBox(height: 15),
//                     CustomTextField(
//                       labelText: '  timePeriod',
//                       controller: _timePeriodController,
//                       suffixIcon: Icons.phone,
//                     ),
//                     SizedBox(height: 30),
//                     TextFormField(
//                       decoration: InputDecoration(
//                         labelText: 'start Date',
//                         labelStyle: TextStyle(color: Color(0xFFa7a7a7)),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15.0),
//                         ),
//                         suffixIcon: Icon(Icons.calendar_today,
//                             size: 25, color: Color(0xFFD0D0D0)),
//                         filled: true,
//                         fillColor: Colors.white,
//                         contentPadding: EdgeInsets.symmetric(
//                             vertical: 12.0, horizontal: 12),
//                       ),
//                       controller: TextEditingController(
//                         text: selectedDate == null
//                             ? ''
//                             : DateFormat('yyyy-MM-dd').format(selectedDate!),
//                       ),
//                       readOnly: true,
//                       onTap: presentDatePicker,
//                     ),
//                     SizedBox(height: 40),
//                     ElevatedButton(
//                       onPressed: _isLoading ? null : _addMedicationReminder,
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor: Color.fromARGB(255, 255, 255, 255),
//                         backgroundColor: Color(0xFF0386D0),
//                         fixedSize: Size(151, 45),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(27.0),
//                         ),
//                       ),
//                       child: Text('Add'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           _isLoading
//               ? Container(
//                   color: Colors.black.withOpacity(0.5),
//                   child: Center(
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         Color(0xff3B5998),
//                       ),
//                     ),
//                   ),
//                 )
//               : SizedBox.shrink(),
//         ],
//       ),
//     );
//   }
// }
