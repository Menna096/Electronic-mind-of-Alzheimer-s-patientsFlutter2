import 'package:easy_localization/easy_localization.dart';

class InputState {
  final String? task;
  final DateTime? dateTime;
  final String? duration;
  final String? list;

  InputState({
    this.task = '',
    DateTime? dateTime,
    String? duration,
    String? list,
  })  : dateTime = dateTime ?? DateTime.now(),
        duration = duration ?? 'No recurrence'.tr(),
        list = list ?? 'Default'.tr();

  InputState copyWith({
    String? task,
    DateTime? dateTime,
    String? duration,
    String? list,
  }) {
    return InputState(
      task: task ?? this.task,
      dateTime: dateTime ?? this.dateTime,
      duration: duration ?? this.duration,
      list: list ?? this.list,
    );
  }
}
