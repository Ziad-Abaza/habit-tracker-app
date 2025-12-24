import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/habit.dart';

part 'habit_repository.g.dart';

class HabitRepository {
  final Box<Habit> _box;

  HabitRepository(this._box);

  static Future<HabitRepository> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitAdapter());
    }
    final box = await Hive.openBox<Habit>('habits');
    return HabitRepository(box);
  }

  List<Habit> getAllHabits() {
    return _box.values.toList();
  }

  List<Habit> getHabitsForDate(DateTime date) {
    final weekday = date.weekday;
    return _box.values.where((habit) {
      if (habit.isArchived) return false;
      
      // Check start/end dates
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (habit.startDate != null) {
        final start = DateTime(habit.startDate!.year, habit.startDate!.month, habit.startDate!.day);
        if (normalizedDate.isBefore(start)) return false;
      }
      if (habit.endDate != null) {
        final end = DateTime(habit.endDate!.year, habit.endDate!.month, habit.endDate!.day);
        if (normalizedDate.isAfter(end)) return false;
      }

      return habit.frequency.contains(weekday);
    }).toList();
  }

  Future<void> addHabit(Habit habit) async {
    await _box.put(habit.id, habit);
  }

  Future<void> updateHabit(Habit habit) async {
    await _box.put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    await _box.delete(id);
  }

  Future<void> toggleCompletion(String id, DateTime date) async {
    final habit = _box.get(id);
    if (habit != null) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final completedDates = List<DateTime>.from(habit.completedDates);

      if (completedDates.any((d) =>
          d.year == normalizedDate.year &&
          d.month == normalizedDate.month &&
          d.day == normalizedDate.day)) {
        completedDates.removeWhere((d) =>
            d.year == normalizedDate.year &&
            d.month == normalizedDate.month &&
            d.day == normalizedDate.day);
      } else {
        completedDates.add(normalizedDate);
      }

      final updatedHabit = habit.copyWith(completedDates: completedDates);
      await _box.put(id, updatedHabit);
    }
  }

  Stream<List<Habit>> watchHabits() {
    return _box.watch().map((event) => _box.values.toList());
  }
}

@riverpod
Future<HabitRepository> habitRepository(Ref ref) async {
  return HabitRepository.init();
}
