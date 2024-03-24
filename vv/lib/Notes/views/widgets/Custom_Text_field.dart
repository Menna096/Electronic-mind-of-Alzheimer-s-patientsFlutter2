import 'package:flutter/material.dart';

class Custom_Text_field extends StatelessWidget {
  const Custom_Text_field(
      {super.key, required this.hint, this.maxlines = 1, this.OnSaved, this.onChanged});
  final String hint;
  final int maxlines;
  final void Function(String?)? OnSaved;
  final Function(String)? onChanged;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged:onChanged ,
      onSaved: OnSaved,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'field is required';
        } else {
          return null;
        }
      },
      cursorColor: Color(0xff3B5998),
      maxLines: maxlines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Color(0xffc4b3a8),
        ),
        border: buildBorder(),
        enabledBorder: buildBorder(),
        focusedBorder: buildBorder(Color(0xff3B5998)),
      ),
    );
  }
}

OutlineInputBorder buildBorder([Color? color]) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
      color: color ?? Color.fromARGB(255, 255, 255, 255),
    ),
  );
}
