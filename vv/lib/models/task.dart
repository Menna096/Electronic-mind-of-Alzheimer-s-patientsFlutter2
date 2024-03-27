import 'package:hive/hive.dart';
 
part 'task.g.dart';
 
@HiveType(typeId: 0)
class Task extends HiveObject{
  late final String name;
  @HiveField(0)
  late final String startTime;
  @HiveField(1)
  late final String endTime;
  @HiveField(2)
  late final String description;
  @HiveField(3)
  late final int day;
  @HiveField(4)
  bool completed;
  @HiveField(5)

  Task({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.day,
    required this.completed,
  });
}
