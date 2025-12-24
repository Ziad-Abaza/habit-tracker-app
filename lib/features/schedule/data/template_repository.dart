import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../domain/weekly_template.dart';
import '../../schedule/data/schedule_repository.dart';
import '../../schedule/domain/time_block.dart';

part 'template_repository.g.dart';

class TemplateRepository {
  final Box<WeeklyTemplate> _box;

  TemplateRepository(this._box);

  static Future<TemplateRepository> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(WeeklyTemplateAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TemplateActivityAdapter());
    }
    final box = await Hive.openBox<WeeklyTemplate>('weekly_templates');
    return TemplateRepository(box);
  }

  List<WeeklyTemplate> getAllTemplates() {
    return _box.values.toList();
  }

  Future<void> addTemplate(WeeklyTemplate template) async {
    await _box.put(template.id, template);
  }

  Future<void> updateTemplate(WeeklyTemplate template) async {
    await _box.put(template.id, template);
  }

  Future<void> deleteTemplate(String id) async {
    await _box.delete(id);
  }

  Future<void> applyTemplate(WeeklyTemplate template, DateTime startOfWeek, ScheduleRepository scheduleRepository) async {
    // Ensure startOfWeek is a Monday
    final monday = startOfWeek.subtract(Duration(days: startOfWeek.weekday - 1));

    for (var entry in template.schedule.entries) {
      final dayOffset = entry.key - 1; // 1-based to 0-based
      final date = monday.add(Duration(days: dayOffset));
      
      for (var activity in entry.value) {
        final startTime = DateTime(
          date.year,
          date.month,
          date.day,
          activity.startHour,
          activity.startMinute,
        );

        final block = TimeBlock(
          id: const Uuid().v4(),
          title: activity.title,
          startTime: startTime,
          durationMinutes: activity.durationMinutes,
          type: activity.type,
        );

        await scheduleRepository.addBlock(block);
      }
    }
  }

  Stream<List<WeeklyTemplate>> watchTemplates() {
    return _box.watch().map((event) => _box.values.toList());
  }
}

@riverpod
Future<TemplateRepository> templateRepository(Ref ref) async {
  return TemplateRepository.init();
}
