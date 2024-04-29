class Appointment {
  late final String location;
  late final String note;
  late final String startTime;

  late final int day;
  bool completed;

  Appointment({
    required this.location,
    required this.startTime,
    required this.day,
    required this.completed,
    required this.note,
  });
}
