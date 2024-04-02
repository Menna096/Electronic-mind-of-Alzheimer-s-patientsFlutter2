import 'package:hive/hive.dart';
 
part 'task.g.dart';
 
@HiveType(typeId: 0)
class Task extends HiveObject{
  late final String name;
  @HiveField(0)
  late final String categories;
  @HiveField(1)
  late final String startTime;
  @HiveField(2)
  late final String endTime;
  @HiveField(3)
  late final String description;
  @HiveField(4)
  late final int day;
  @HiveField(5)
  bool completed;
  @HiveField(6)

  Task({
     required this.name,
    required this.categories,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.day,
    required this.completed,
  });
}
