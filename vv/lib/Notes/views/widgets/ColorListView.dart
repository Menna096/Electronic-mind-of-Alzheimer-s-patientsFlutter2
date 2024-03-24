import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vv/Notes/cubits/Add_notes_cubit.dart';


class ColorItem extends StatelessWidget {
  const ColorItem({Key? key, required this.isactive, required this.color})
      : super(key: key);
  final bool isactive;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return isactive
        ? CircleAvatar(
            backgroundColor: Colors.white,
            radius: 38,
            child: CircleAvatar(
              radius: 34,
              backgroundColor: color,
            ),
          )
        : CircleAvatar(
            radius: 38,
            backgroundColor: color,
          );
  }
}

class ColorListView extends StatefulWidget {
  const ColorListView({Key? key}) : super(key: key);

  @override
  State<ColorListView> createState() => _ColorListViewState();
}

class _ColorListViewState extends State<ColorListView> {
  int currentindex = 0;
  List<Color> colors = [
    
    Color(0xffD3D0C5),
    Color(0xff9E898E),
    Color(0xff886B69),
    Color(0xff635757),
    Color(0xff93776A),
    Color(0xffDBD5CA),
    Color(0xffB9AE99),
    Color(0xff5C564B),
    Color(0xff897F6E),
    Color(0xff8F8D81),
    Color(0xff6C5E2F),
    Color(0xff957B5E),
    Color(0xff754D36),
  ];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38 * 2,
      child: ListView.builder(
        itemCount: colors.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () {
                currentindex = index;
                BlocProvider.of<AddNotesCubit>(context).color = colors[index];
                setState(() {});
              },
              child: ColorItem(
                color: colors[index],
                isactive: currentindex == index,
              ),
            ),
          );
        },
      ),
    );
  }
}
