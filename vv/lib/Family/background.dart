import 'package:flutter/material.dart';
import 'package:vv/Family/LoginPageAll.dart';


class Background extends StatelessWidget {
  final Widget child;

  const Background({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xffFFFFFF),
            Color(0xff3B5998),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 45),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF526CA4).withOpacity(0.2),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.grey),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPageAll(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}