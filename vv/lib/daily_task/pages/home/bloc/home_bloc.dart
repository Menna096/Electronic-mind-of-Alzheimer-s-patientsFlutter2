import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vv/daily_task/pages/home/bloc/home_event.dart';
import 'package:vv/daily_task/pages/home/bloc/home_state.dart';


class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<DoneTaskEvent>(_doneTaskEvent);
  }
  void _doneTaskEvent(DoneTaskEvent event, Emitter<HomeState> emit) {
    emit(state.copywith(done: event.done));
  }
}
