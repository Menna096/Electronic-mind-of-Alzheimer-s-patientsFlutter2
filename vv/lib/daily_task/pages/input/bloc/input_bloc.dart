import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vv/daily_task/pages/input/bloc/input_event.dart';
import 'package:vv/daily_task/pages/input/bloc/input_state.dart';


class InputBloc extends Bloc<InputEvent, InputState> {
  InputBloc() : super(InputState()) {
    on<TaskEvent>(_taskEvent);
    on<DateAndTimeEvent>(_dateTimeEvent);
    on<RecurrenceEvent>(_recurrenceEvent);
    on<ListEvent>(_listEvent);
  }

  void _taskEvent(TaskEvent event, Emitter<InputState> emit) {
    emit(state.copyWith(task: event.task));
  }

  void _dateTimeEvent(DateAndTimeEvent event, Emitter<InputState> emit) {
    emit(state.copyWith(dateTime: event.dateTime));
  }

  void _recurrenceEvent(RecurrenceEvent event, Emitter<InputState> emit) {
    emit(state.copyWith(duration: event.duration));
  }

  void _listEvent(ListEvent event, Emitter<InputState> emit) {
    emit(state.copyWith(list: event.list));
  }
}
