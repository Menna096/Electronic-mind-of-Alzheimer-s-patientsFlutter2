import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:vv/Caregiver/mainpagecaregiver/patient_list.dart';
import 'package:vv/Family/ForgotPasswordfamily.dart';
import 'package:vv/Family/Registerfamily/registerfamily.dart';
import 'package:vv/Family/String_manager.dart';
import 'package:vv/Family/assignOrAdd.dart';
import 'package:vv/Family/enterimage.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:vv/api/local_auth_api.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/utils/token_manage.dart';

class LoginPageAll extends StatefulWidget {
  @override
  _LoginPageAllState createState() => _LoginPageAllState();
}

class _LoginPageAllState extends State<LoginPageAll> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';
  bool _isPasswordVisible = false;
  String _emailErrorText = '';
  String _passwordErrorText = '';
  bool _isBiometricEnabled = false;
  bool _isLoading = false;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();

    _checkTokenAndEnableBiometric().then((_) {
      if (_isBiometricEnabled) {
        _authenticateWithBiometric();
      }
    });
  }

  Future<void> _checkTokenAndEnableBiometric() async {
    final String? token = await TokenManager.getToken();
    if (token != null) {
      setState(() {
        _isBiometricEnabled = true;
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _emailErrorText = '';
      _passwordErrorText = '';
    });

    final String email = _emailController.text;
    final String password = _passwordController.text;

    try {
      if (!_validateEmail(email)) {
        setState(() {
          _emailErrorText = context.tr(StringManager.invalid_email);
          _isLoading = false;
        });
        return;
      }

      final response = await Dio().post(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Authentication/Login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'];
      await TokenManager.setToken(token);
      _handleLoginSuccess(token);
    } catch (error) {
      if (error is DioError) {
        if (error.response != null) {
          switch (error.response!.statusCode) {
            case 401:
              _showErrorDialog(context.tr(StringManager.login_error_401));
              break;
            case 400:
              _showErrorDialog(context.tr(StringManager.login_error_400));
              break;
            case 404:
              _showErrorDialog(context.tr(StringManager.login_error_404));
              break;
            case 500:
              _showErrorDialog(context.tr(StringManager.login_error_500));
              break;
            default:
              _showErrorDialog(context.tr(StringManager.login_error_default));
          }
        } else {
          _showErrorDialog(
              context.tr(StringManager.server_error));
        }
      } else {
        _showErrorDialog(context.tr(StringManager.login_error_default));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateEmail(String email) {
    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$");
    return emailRegExp.hasMatch(email);
  }

  void _handleLoginSuccess(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String userRole = decodedToken['roles'];

    if (userRole == 'Family') {
      checkTrain();
    } else if (userRole == 'Caregiver') {
      _navigateToMainPageCaregiver();
    } else {
      Navigator.pushReplacement(
        context,
        _createRoute(mainpatient()),
      );
    }
  }

  PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr(StringManager.LoginError),),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text((context.tr(StringManager.OK))
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _authenticateWithBiometric() async {
    final isAuthenticated = await LocalAuthApi.authenticate();
    if (isAuthenticated) {
      _navigateBasedOnUserRole();
    } else {
      print('Fingerprint authentication failed.');
    }
  }

  void _navigateToMainPageFamily() {
    Navigator.pushReplacement(
      context,
      _createRoute(MainPageFamily()),
    );
  }

  void _navigateToMainPageCaregiver() {
    Navigator.pushReplacement(
      context,
      _createRoute(PatientListScreen()),
    );
  }

  Future<void> checkTrain() async {
    try {
      Response response = await DioService().dio.get(
            'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/FamilyNeedATrainingImages',
          );

      if (response.statusCode == 200) {
        bool needTraining = response.data['needATraining'];

        if (needTraining == true) {
          Navigator.push(
            context,
            _createRoute(UploadImagesPage()),
          );
          print('need to train');
        } else if (needTraining == false) {
          _navigateToMainPageFamily();
        } else {
          Navigator.push(
            context,
            _createRoute(assign_add()),
          );
        }
      } else {
        Navigator.push(
          context,
          _createRoute(assign_add()),
        );
      }
    } catch (e) {
      Navigator.push(
        context,
        _createRoute(assign_add()),
      );
      print('Error: $e');
    }
  }

  Future<void> _navigateBasedOnUserRole() async {
    final token = await TokenManager.getToken();
    if (token != null) {
      if (token.isNotEmpty) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String userRole = decodedToken['roles'];

        if (userRole == 'Family') {
          checkTrain();
        } else if (userRole == 'Caregiver') {
          _navigateToMainPageCaregiver();
        } else {
          Navigator.pushReplacement(
            context,
            _createRoute(mainpatient()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Color(0xff3B5998),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xffFFFFFF),
                    Color(0xff3B5998),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 50.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 110),
                      Text(
                        context.tr(StringManager.Welcome),
                        style: TextStyle(
                          fontSize: 58,
                          fontFamily: 'LilitaOne',
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: [Colors.blue[400]!, Colors.indigo[400]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(
                              Rect.fromLTWH(
                                  0, 0, 400, 10), // Adjust the size as needed
                            ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 50.0),
                      _buildEmailTextField(),
                      SizedBox(height: 11),
                      _buildPasswordTextField(),
                      SizedBox(height: 50.0),
                      _isLoading
                          ? CircularProgressIndicator()
                          : _buildLoginButton(),
                      SizedBox(height: 10.0),
                      _buildRegisterNowButton(),
                      SizedBox(height: 10.0),
                      _buildForgotPasswordButton(),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ),
            ),
            _buildLanguageIconButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        hintText: context.tr(StringManager.EmailAddress),
        prefixIcon: Icon(
          Icons.email,
          color: Color.fromARGB(255, 60, 111, 212),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
        errorText: _emailErrorText,
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      obscureText: !_isPasswordVisible,
      controller: _passwordController,
      decoration: InputDecoration(
        hintText: context.tr(StringManager.password),
        prefixIcon: Icon(
          Icons.lock,
          color: Color.fromARGB(255, 60, 111, 212),
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Color.fromARGB(255, 229, 236, 251),
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
        errorText: _passwordErrorText,
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
          setState(() {
            _emailErrorText = context.tr(StringManager.enter_email);
            _passwordErrorText = context.tr(StringManager.enter_password);
          });
          return;
        }
        _login();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 145.0, vertical: 15.0),
        textStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 81, 122, 203)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      child: Text(
        context.tr(StringManager.login),
      ),
    );
  }

  Widget _buildRegisterNowButton() {
    return TextButton(
      onPressed: () {
        TokenManager.deleteToken();
        Navigator.push(
          context,
          _createRoute(RegisterFamily()),
        );
      },
      style: TextButton.styleFrom(
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          children: <TextSpan>[
            TextSpan(
                text: context.tr(StringManager.donthaveanaccount),
                style: TextStyle(color: Colors.white)),
            TextSpan(
              text: context.tr(StringManager.registerNow),
              style: TextStyle(
                fontFamily: 'Outfit',
                color: Color.fromARGB(255, 20, 66, 158),
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        TokenManager.deleteToken();
        Navigator.push(
          context,
          _createRoute(ForgotPasswordfamily()),
        );
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          children: <TextSpan>[
            TextSpan(
                text: context.tr(StringManager.Help),
                style: TextStyle(color: Colors.white)),
            TextSpan(
              text: context.tr(StringManager.ForgotPassword),
              style: TextStyle(
                fontFamily: 'Outfit',
                color: Color.fromARGB(255, 17, 59, 143),
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLanguageIconButton() {
    return Positioned(
      top: 50.0,
      left: 20.0,
      child: IconButton(
        icon: Icon(
          Icons.language,
          color: Color.fromARGB(177, 28, 80, 183),
          size: 30,
        ),
        onPressed: () {
          _showLanguageMenu();
        },
      ),
    );
  }

 void _showLanguageMenu() {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35.0), // Rounded corners
      ),
      child: Container(
        padding: EdgeInsets.all(25.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr(StringManager.ChooseLanguage),

              style: TextStyle(
                fontSize: 20,
               
                fontFamily: 'Acme',
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.language,color:Color.fromARGB(255, 17, 59, 143),),
              title: Text('English'),
              onTap: () {
                context.setLocale(Locale('en'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.language,color: Color.fromARGB(255, 17, 59, 143),),
              title: Text('العربية'),
              onTap: () {
                context.setLocale(Locale('ar'));
                Navigator.of(context).pop();
              },
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.tr(StringManager.Cancel),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
