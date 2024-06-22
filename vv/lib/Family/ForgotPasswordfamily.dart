import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/widgets/backbutton.dart';
import 'package:vv/widgets/background.dart';
import 'package:vv/widgets/text_forgot_var_set.dart';

class ForgotPasswordfamily extends StatefulWidget {
  @override
  _ForgotPasswordfamilyState createState() => _ForgotPasswordfamilyState();
}

class _ForgotPasswordfamilyState extends State<ForgotPasswordfamily> {
  final _emailController = TextEditingController();
  final _dio = Dio();
  final _storage = FlutterSecureStorage();
  String _emailError = '';
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;

  Future<void> _forgotPassword(String email) async {
    setState(() {
      _loading = true;
    });
    try {
      Response response = await _dio.post(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Authentication/ForgetPassword',
        queryParameters: {'email': email},
        data: {},
      );

      _showDialog(
        response.statusCode == 200 ? 'successTitle'.tr() : 'errorTitle'.tr(),
        response.statusCode == 200
            ? 'successMessage'.tr(namedArgs: {'email': email})
            : 'errorTitle'.tr(),
        response.statusCode == 200
            ? () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPageAll()),
                );
              }
            : () {
                Navigator.pop(context);
              },
      );
    } on DioError catch (e) {
      String errorMessage =
          'unexpectedGeneralError'.tr(namedArgs: {'error': e.toString()});
      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 400:
            errorMessage = 'noUserError'.tr();
            break;
          case 500:
            errorMessage = 'serverError'.tr();
            break;
          default:
            errorMessage = 'unexpectedError'.tr(
                namedArgs: {'statusCode': e.response!.statusCode.toString()});
            break;
        }
      } else {
        errorMessage = 'networkError'.tr();
      }
      _showDialog('errorTitle'.tr(), errorMessage, () {
        Navigator.pop(context);
      });
    } catch (e) {
      _showDialog('errorTitle'.tr(),
          'unexpectedGeneralError'.tr(namedArgs: {'error': e.toString()}), () {
        Navigator.pop(context);
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showDialog(String title, String content, Function() onPressed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: onPressed,
            child: Text('ok'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 30, color: Color(0xff3B5998)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Background(
            SingleChildScrollView: null,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ForgetPass_var_setpass_Text(text: 'forgotPassword'.tr()),
                  SizedBox(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 10, top: 30),
                        child: Image.asset(
                          'images/forgotpass.png',
                          width: 350,
                          height: 260,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                
                  
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'emailHint'.tr(),
                        prefixIcon: Icon(
                          Icons.email,
                          color: Color.fromARGB(255, 218, 216, 216),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        errorText: _emailError,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.0),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        String email = _emailController.text.trim();
                        if (email.isNotEmpty) {
                          _forgotPassword(email);
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('errorTitle'.tr()),
                              content: Text('pleaseEnterEmail'.tr()),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('ok'.tr()),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF0386D0),
                        padding:
                            EdgeInsets.symmetric(vertical: 18, horizontal: 30),
                        textStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'ok'.tr(),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xff3B5998),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
