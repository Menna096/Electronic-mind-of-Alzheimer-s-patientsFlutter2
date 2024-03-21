import 'package:flutter/material.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/api/local_auth_api.dart';
import 'package:vv/widgets/imagefingerandface.dart';

class biometric_login extends StatelessWidget {
  const biometric_login({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () async {
                  final isAuthenticated = await LocalAuthApi.authenticate();

                  if (isAuthenticated) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => mainpagefamily(),
                      ),
                    );
                  }
                },
                child: Images(
                  image: 'images/fingerprint.png',
                  width: 70,
                  height: 70,
                ),
              )),
        ),
        Images(
          image: 'images/face-recognition.png',
          width: 65,
          height: 65,
        ),
      ],
    );
  }
}
