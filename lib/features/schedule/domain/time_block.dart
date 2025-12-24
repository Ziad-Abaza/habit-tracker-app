import 'package:hive/hive.dart';

part 'time_block.g.dart';

@HiveType(typeId: 3)
class TimeBlock {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final String type; // 'work', 'study', 'exercise', 'rest', 'other'

  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final String? categoryId;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final int? color;

  @HiveField(9)
  final int? icon;

  TimeBlock({
    required this.id,
    required this.title,
    required this.startTime,
    required this.durationMinutes,
    required this.type,
    this.isCompleted = false,
    this.categoryId,
    this.notes,
    this.color,
    this.icon,
  });

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  TimeBlock copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    int? durationMinutes,
    String? type,
    String? categoryId,
    String? notes,
    int? color,
    int? icon,
  }) {
    return TimeBlock(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      categoryId: categoryId ?? this.categoryId,
      notes: notes ?? this.notes,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}
