import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:vv/Notes/models/note_model.dart';
part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesInitial());
  List<NoteModel>? notes;
  FetchAllNotes() {
    var notesbox = Hive.box<NoteModel>('Notes_Box');
    notes = notesbox.values.toList();
    emit(NotesSuccess());
  }
}
