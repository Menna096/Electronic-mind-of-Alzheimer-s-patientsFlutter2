import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/widgets/background.dart';
import 'package:geolocator/geolocator.dart';

class PatientProfManage extends StatefulWidget {
  @override
  _PatientProfManageState createState() => _PatientProfManageState();
}

class _PatientProfManageState extends State<PatientProfManage> {
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  DateTime? _selectedDate;

  bool _isEditingPhone = false;
  bool _isEditingAge = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
        });
      }
    });
  }

  Future<void> _fetchUserData() async {
    try {
      var response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetPatientProfile');
      if (response.statusCode == 200) {
        setState(() {
          _fullNameController.text = response.data['fullName'];
          _phoneController.text = response.data['phoneNumber'];
          _ageController.text = response.data['age'].toString();
          _selectedDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
              .parse(response.data['diagnosisDate']);
          messageController.text = response.data['message'];
          _idController.text = response.data['patientId'];
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> updateUserProfile() async {
    String apiUrl =
        'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/UpdatePatientProfile';
    Map<String, dynamic> requestBody = {
      'phoneNumber': _phoneController.text,
      'age': int.parse(_ageController.text),
      'patientId': _idController.text,
      'fullName': _fullNameController.text,
      'diagnosisDate': _selectedDate != null
          ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(_selectedDate!)
          : null,
      'message': messageController.text,
    };

    try {
      Response response = await DioService().dio.put(
            apiUrl,
            data: requestBody,
            options: Options(
              contentType: 'application/json; charset=UTF-8',
            ),
          );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile Updated Successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Failed to update profile. Status code: ${response.statusCode}')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'View Profile',
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
              bottom: Radius.circular(10.0),
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
      body: Background(
        SingleChildScrollView: null,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                _buildTextField(
                  labelText: 'Welcome Message To Patient',
                  controller: messageController,
                  maxLines: 1,
                  readOnly: true,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  labelText: 'Your ID',
                  controller: _idController,
                  readOnly: true,
                  maxLines: 2,
                  prefixIcon: Icon(
                    Icons.assignment_ind_sharp, // Changed icon to a phone icon
                    color: Color.fromARGB(255, 106, 184, 217),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  labelText: 'Full Name',
                  controller: _fullNameController,
                  readOnly: true,
                  prefixIcon: Icon(
                    Icons.person, // Changed icon to a phone icon
                    color: Color.fromARGB(255, 106, 184, 217),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  labelText: 'Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(
                    Icons.phone_android, // Changed icon to a phone icon
                    color: Color.fromARGB(255, 106, 184, 217),
                  ),
                  readOnly: !_isEditingPhone,
                  suffixIcon: _isEditingPhone
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              _isEditingPhone = false;
                            });
                          },
                          icon: Icon(Icons.check,color: Color.fromARGB(227, 28, 107, 181),),
                        )
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              _isEditingPhone = true;
                            });
                          },
                          icon: Icon(Icons.edit,color: Color.fromARGB(225, 166, 167, 169),),
                        ),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  labelText: 'Age',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(
                    Icons.event_busy_outlined, // Changedicon to a person icon
                    color: Color.fromARGB(255, 106, 184, 217),
                  ),
                  readOnly: !_isEditingAge,
                  suffixIcon: _isEditingAge
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              _isEditingAge = false;
                            });
                          },
                          icon: Icon(Icons.check,color: Color.fromARGB(227, 28, 107, 181),),
                        )
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              _isEditingAge = true;
                            });
                          },
                          icon: Icon(Icons.edit,color: Color.fromARGB(225, 166, 167, 169),),
                        ),
                ),
                SizedBox(height: 20),
                ListTile(
                  title: Text(
                    'Diagnosis Date: ${_selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : "Not set"}',
                    style: TextStyle(fontSize: 16,
                    fontFamily: 'LilitaOne',
                    color: Color.fromARGB(168, 21, 26, 30)),
                  ),
                  onTap: _presentDatePicker,
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: updateUserProfile,
                  child: Text('Update Profile',
                  style: TextStyle(fontSize: 16,
                    fontFamily: 'LilitaOne',
                  ),),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    Icon? prefixIcon, // Added prefixIcon parameter
    Widget? suffixIcon, // Added suffixIcon parameter
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(
            255, 212, 234, 249), // Background color for the text field
        borderRadius: BorderRadius.circular(12), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 105, 105, 105),
            offset: Offset(3, 3),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Color.fromARGB(255, 202, 201, 201),
            offset: Offset(-3, -3),
            blurRadius: 6,
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
          hintText: 'Enter $labelText',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none, // No border, just the container shadow
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          prefixIcon: prefixIcon, // Added prefixIcon here
          suffixIcon: suffixIcon, // Added suffixIcon here
        ),
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}