import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final List<int> frequency; // Days of week (1-7)

  @HiveField(4)
  final DateTime? time; // Specific time for the habit

  @HiveField(5)
  final int durationMinutes;

  @HiveField(6)
  final List<DateTime> completedDates;

  @HiveField(7)
  final bool isArchived;

  @HiveField(8)
  final String? categoryId;

  @HiveField(9)
  final DateTime? startDate;

  @HiveField(10)
  final DateTime? endDate;

  @HiveField(11)
  final List<DateTime>? reminders;

  Habit({
    required this.id,
    required this.title,
    this.description = '',
    required this.frequency,
    this.time,
    this.durationMinutes = 0,
    this.completedDates = const [],
    this.isArchived = false,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.reminders,
  });

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    List<int>? frequency,
    DateTime? time,
    int? durationMinutes,
    List<DateTime>? completedDates,
    bool? isArchived,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    List<DateTime>? reminders,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      time: time ?? this.time,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      completedDates: completedDates ?? this.completedDates,
      isArchived: isArchived ?? this.isArchived,
      categoryId: categoryId ?? this.categoryId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reminders: reminders ?? this.reminders,
    );
  }

  bool get isCompletedToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return completedDates.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  bool isCompletedOnDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return completedDates.any((d) {
      final normalizedCompleted = DateTime(d.year, d.month, d.day);
      return normalizedCompleted.year == normalizedDate.year &&
          normalizedCompleted.month == normalizedDate.month &&
          normalizedCompleted.day == normalizedDate.day;
    });
  }
}
