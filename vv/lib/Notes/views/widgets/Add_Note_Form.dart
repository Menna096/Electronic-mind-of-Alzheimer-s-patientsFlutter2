import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vv/Notes/cubits/Add_notes_cubit.dart';
import 'package:vv/Notes/models/note_model.dart';
import 'package:vv/Notes/views/widgets/ColorListView.dart';
import 'package:vv/Notes/views/widgets/Custom_Text_field.dart';
import 'package:vv/Notes/views/widgets/custombutton.dart';

class Add_Note_Form extends StatefulWidget {
  const Add_Note_Form({super.key});

  @override
  State<Add_Note_Form> createState() => _Add_Note_FormState();
}

// ignore: camel_case_types
class _Add_Note_FormState extends State<Add_Note_Form> {
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  final GlobalKey<FormState> formKey = GlobalKey();
  String? title, subtitle;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Column(
        children: [
          const SizedBox(
            height: 32,
          ),
          Custom_Text_field(
            hint: 'Title'.tr(),
            OnSaved: (value) {
              title = value;
            },
          ),
          
          const SizedBox(
            height: 16,
          ),
          Custom_Text_field(
            hint: 'Content'.tr(),
            maxlines: 7,
            OnSaved: (value) {
              subtitle = value;
            },
          ),
           const SizedBox(
            height: 16,
          ),
          const ColorListView(),
          const SizedBox(height: 16),
          BlocBuilder<AddNotesCubit, AddNotesState>(builder: (context, State) {
            return custombutton(
              isloading: State is AddNotesLoading ? true : false,
              onTap: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  var CurrentDate = DateTime.now();
                  var formattedCurrentDate =
                      DateFormat('dd-MM-yyyy').format(CurrentDate);
                  BlocProvider.of<AddNotesCubit>(context).AddNote(
                    NoteModel(
                        title: title!,
                        subtitle: subtitle!,
                        date: formattedCurrentDate,
                        color: const Color.fromARGB(255, 0, 0, 0).value),
                  );
                } else {
                  autovalidateMode = AutovalidateMode.always;
                  setState(() {});
                }
              },
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

