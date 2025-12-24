import 'package:hive/hive.dart';

part 'weekly_template.g.dart';

@HiveType(typeId: 1)
class WeeklyTemplate {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final Map<int, List<TemplateActivity>> schedule; // Day (1-7) -> Activities

  WeeklyTemplate({
    required this.id,
    required this.name,
    required this.schedule,
  });
}

@HiveType(typeId: 2)
class TemplateActivity {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final int startHour;

  @HiveField(2)
  final int startMinute;

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final String type; // 'work', 'study', 'exercise', 'rest', 'other'

  TemplateActivity({
    required this.title,
    required this.startHour,
    required this.startMinute,
    required this.durationMinutes,
    required this.type,
  });
}
