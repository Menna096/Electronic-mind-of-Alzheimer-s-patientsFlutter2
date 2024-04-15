class Appointment {
  late final String name;
  late final String place;
  late final String startTime;
  late final String endTime;
  late final String description;
  late final int day;
  bool completed;

  Appointment({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.day,
    required this.completed,
    required this.place,
  });
}
