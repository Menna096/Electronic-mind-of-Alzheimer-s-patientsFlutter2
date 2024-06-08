import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../../models/errors.dart';
import '../../models/medicine_type.dart';

class NewEntryBloc {
  BehaviorSubject<int>? _selectedMedicineType$;
  ValueStream<int>? get selectedMedicineType =>
      _selectedMedicineType$!.stream;

  BehaviorSubject<int>? _selectedInterval$;
  BehaviorSubject<int>? get selectIntervals => _selectedInterval$;

  BehaviorSubject<TimeOfDay>? _selectedTimeOfDay$;
  BehaviorSubject<TimeOfDay>? get selectedTimeOfDay$ => _selectedTimeOfDay$;

  BehaviorSubject<DateTime>? _selectedDate$;
  BehaviorSubject<DateTime>? get selectedDate$ => _selectedDate$;

  //error state
  BehaviorSubject<EntryError>? _errorState$;
  BehaviorSubject<EntryError>? get errorState$ => _errorState$;

  NewEntryBloc() {
    _selectedMedicineType$ =
        BehaviorSubject<int>.seeded(-1);

    _selectedTimeOfDay$ =
        BehaviorSubject<TimeOfDay>.seeded(const TimeOfDay(hour: 0, minute: 0));
    _selectedDate$ = BehaviorSubject<DateTime>.seeded(DateTime.now());
    _selectedInterval$ = BehaviorSubject<int>.seeded(0);
    _errorState$ = BehaviorSubject<EntryError>();
  }

  void dispose() {
    _selectedMedicineType$!.close();
    _selectedTimeOfDay$!.close();
    _selectedDate$!.close();
    _selectedInterval$!.close();
  }

  void submitError(EntryError error) {
    _errorState$!.add(error);
  }

  void updateInterval(int interval) {
    _selectedInterval$!.add(interval);
  }

  void updateTime(TimeOfDay time) {
    _selectedTimeOfDay$!.add(time);
  }

  void updateDate(DateTime date) {
    _selectedDate$!.add(date);
  }

  void updateSelectedMedicine(int type) {
    _selectedMedicineType$!.add(type);
  }
}
