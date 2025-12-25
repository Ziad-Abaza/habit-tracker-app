import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/settings.dart';

part 'settings_repository.g.dart';

class SettingsRepository {
  final Box _box;
  static const String _settingsBoxName = 'settings';
  static const String _themeModeKey = 'themeMode';
  static const String _notificationsEnabledKey = 'notificationsEnabled';
  static const String _firstDayOfWeekKey = 'firstDayOfWeek';
  static const String _hapticFeedbackKey = 'hapticFeedback';
  static const String _showConfettiKey = 'showConfetti';
  static const String _compactViewKey = 'compactView';
  static const String _showAllDaysKey = 'showAllDays';
  static const String _endOfDayReminderKey = 'endOfDayReminder';
  static const String _endOfDayReminderHourKey = 'endOfDayReminderHour';
  static const String _endOfDayReminderMinuteKey = 'endOfDayReminderMinute';
  static const String _hasSeenOnboardingKey = 'hasSeenOnboarding';

  SettingsRepository(this._box);

  static Future<SettingsRepository> init() async {
    final box = await Hive.openBox(_settingsBoxName);
    return SettingsRepository(box);
  }

  AppSettings getSettings() {
    final themeIndex = _box.get(_themeModeKey, defaultValue: ThemeMode.system.index) as int;
    final notificationsEnabled = _box.get(_notificationsEnabledKey, defaultValue: true) as bool;
    final firstDayOfWeek = _box.get(_firstDayOfWeekKey, defaultValue: DateTime.monday) as int;
    final hapticFeedback = _box.get(_hapticFeedbackKey, defaultValue: true) as bool;
    final showConfetti = _box.get(_showConfettiKey, defaultValue: true) as bool;
    final compactView = _box.get(_compactViewKey, defaultValue: false) as bool;
    final showAllDays = _box.get(_showAllDaysKey, defaultValue: false) as bool;
    final endOfDayReminder = _box.get(_endOfDayReminderKey, defaultValue: false) as bool;
    final endOfDayReminderHour = _box.get(_endOfDayReminderHourKey, defaultValue: 21) as int;
    final endOfDayReminderMinute = _box.get(_endOfDayReminderMinuteKey, defaultValue: 0) as int;
    final hasSeenOnboarding = _box.get(_hasSeenOnboardingKey, defaultValue: false) as bool;

    return AppSettings(
      themeMode: ThemeMode.values[themeIndex],
      notificationsEnabled: notificationsEnabled,
      firstDayOfWeek: firstDayOfWeek,
      hapticFeedback: hapticFeedback,
      showConfetti: showConfetti,
      compactView: compactView,
      showAllDays: showAllDays,
      endOfDayReminder: endOfDayReminder,
      endOfDayReminderTime: TimeOfDay(hour: endOfDayReminderHour, minute: endOfDayReminderMinute),
      hasSeenOnboarding: hasSeenOnboarding,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _box.put(_themeModeKey, mode.index);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _box.put(_notificationsEnabledKey, enabled);
  }

  Future<void> setFirstDayOfWeek(int day) async {
    await _box.put(_firstDayOfWeekKey, day);
  }

  Future<void> setHapticFeedback(bool enabled) async {
    await _box.put(_hapticFeedbackKey, enabled);
  }

  Future<void> setShowConfetti(bool enabled) async {
    await _box.put(_showConfettiKey, enabled);
  }

  Future<void> setCompactView(bool enabled) async {
    await _box.put(_compactViewKey, enabled);
  }

  Future<void> setShowAllDays(bool enabled) async {
    await _box.put(_showAllDaysKey, enabled);
  }

  Future<void> setEndOfDayReminder(bool enabled) async {
    await _box.put(_endOfDayReminderKey, enabled);
  }

  Future<void> setEndOfDayReminderTime(TimeOfDay time) async {
    await _box.put(_endOfDayReminderHourKey, time.hour);
    await _box.put(_endOfDayReminderMinuteKey, time.minute);
  }

  Future<void> setHasSeenOnboarding(bool seen) async {
    await _box.put(_hasSeenOnboardingKey, seen);
  }

  Future<void> clearAllData() async {
    // This is a placeholder for a more comprehensive clear data function
    // that would clear all boxes (habits, schedule, etc.)
    await Hive.deleteBoxFromDisk('habits');
    await Hive.deleteBoxFromDisk('templates');
    await Hive.deleteBoxFromDisk('schedule');
    await _box.clear();
  }
}

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  throw UnimplementedError();
}
