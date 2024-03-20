import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_btn/loading_btn.dart';
import 'package:vv/Family/LoginPageAll.dart';

class loading_button extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 1),
        LoadingBtn(
          height: 50,
          width: 365,
          borderRadius: 27,
          animate: true,
          color: Color.fromARGB(255, 54, 153, 210),
          loader: Container(
            padding: EdgeInsets.all(10),
            child: Center(
              child: SpinKitDoubleBounce(
                color: Colors.white,
              ),
            ),
          ),
          onTap: (startLoading, stopLoading, btnState) async {
            if (btnState == ButtonState.idle) {
              startLoading();
              // call your network api
              await Future.delayed(const Duration(seconds: 5));

              stopLoading();
              LoginPageAll();
            }
          },
          child: Text(
            "Login",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
