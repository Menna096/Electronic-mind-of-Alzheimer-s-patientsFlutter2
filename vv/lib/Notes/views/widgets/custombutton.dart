import 'package:flutter/material.dart';

class custombutton extends StatelessWidget {
  const custombutton({super.key, this.onTap, this.isloading = false});

  final void Function()? onTap;
  final bool isloading;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0xff3B5998),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: isloading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Color(0xFF2D2D2D),
                  ),
                )
              : const Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'PatuaOne',
                    color: Color.fromARGB(255, 215, 215, 215),
                  ),
                ),
        ),
      ),
    );
  }
}
