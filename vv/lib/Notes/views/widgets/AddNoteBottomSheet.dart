import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vv/Notes/cubits/Add_notes_cubit.dart';
import 'package:vv/Notes/cubits/notes_cubit/notes_cubit.dart';
import 'package:vv/Notes/views/widgets/Add_Note_Form.dart';

class AddNoteBottomSheet extends StatefulWidget {
  const AddNoteBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddNoteBottomSheet> createState() => _AddNoteBottomSheetState();
}

class _AddNoteBottomSheetState extends State<AddNoteBottomSheet> {
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddNotesCubit>(
      create: (context) => AddNotesCubit(),
      child: BlocConsumer<AddNotesCubit, AddNotesState>(
        listener: (context, state) {
          if (state is AddNotesFailure) {
            
          }
          if (state is AddNotesSuccess) {
            BlocProvider.of<NotesCubit>(context).FetchAllNotes();
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return AbsorbPointer(
            absorbing: state is AddNotesLoading ? true : false,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: const SingleChildScrollView(
                child: Add_Note_Form(),
              ),
            ),
          );
        },
      ),
    );
  }
}
