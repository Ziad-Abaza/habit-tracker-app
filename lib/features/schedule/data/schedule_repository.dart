import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/time_block.dart';

part 'schedule_repository.g.dart';

class ScheduleRepository {
  final Box<TimeBlock> _box;

  ScheduleRepository(this._box);

  static Future<ScheduleRepository> init() async {
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TimeBlockAdapter());
    }
    final box = await Hive.openBox<TimeBlock>('schedule');
    return ScheduleRepository(box);
  }

  List<TimeBlock> getBlocksForDate(DateTime date) {
    return _box.values.where((block) {
      return block.startTime.year == date.year &&
          block.startTime.month == date.month &&
          block.startTime.day == date.day;
    }).toList();
  }

  Future<void> addBlock(TimeBlock block) async {
    await _box.put(block.id, block);
  }

  TimeBlock? getBlock(String id) {
    return _box.get(id);
  }

  Future<void> updateBlock(TimeBlock block) async {
    await _box.put(block.id, block);
  }

  Future<void> deleteBlock(String id) async {
    await _box.delete(id);
  }

  List<TimeBlock> getAllBlocks() {
    return _box.values.toList();
  }

  Stream<List<TimeBlock>> watchAllSchedule() {
    return _box.watch().map((event) => _box.values.toList());
  }

  Stream<List<TimeBlock>> watchSchedule(DateTime date) {
    return _box.watch().map((event) {
      return _box.values.where((block) {
        return block.startTime.year == date.year &&
            block.startTime.month == date.month &&
            block.startTime.day == date.day;
      }).toList();
    });
  }

  bool checkForConflicts(TimeBlock newBlock) {
    final blocks = getBlocksForDate(newBlock.startTime);
    for (var block in blocks) {
      if (block.id == newBlock.id) continue; // Skip self if updating

      final newStart = newBlock.startTime;
      final newEnd = newBlock.endTime;
      final blockStart = block.startTime;
      final blockEnd = block.endTime;

      if (newStart.isBefore(blockEnd) && newEnd.isAfter(blockStart)) {
        return true; // Conflict found
      }
    }
    return false;
  }
}

@riverpod
Future<ScheduleRepository> scheduleRepository(Ref ref) async {
  return ScheduleRepository.init();
}
