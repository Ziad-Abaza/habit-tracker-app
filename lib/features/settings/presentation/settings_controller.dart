import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/settings.dart';
import '../data/settings_repository.dart';
import '../../../core/notifications/notification_service.dart';

part 'settings_controller.g.dart';

@riverpod
class SettingsController extends _$SettingsController {
  late SettingsRepository _repository;

  @override
  AppSettings build() {
    _repository = ref.watch(settingsRepositoryProvider);
    return _repository.getSettings();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repository.setThemeMode(mode);
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _repository.setNotificationsEnabled(enabled);
  }

  Future<void> setFirstDayOfWeek(int day) async {
    state = state.copyWith(firstDayOfWeek: day);
    await _repository.setFirstDayOfWeek(day);
  }

  Future<void> toggleHapticFeedback(bool enabled) async {
    state = state.copyWith(hapticFeedback: enabled);
    await _repository.setHapticFeedback(enabled);
  }

  Future<void> toggleShowConfetti(bool enabled) async {
    state = state.copyWith(showConfetti: enabled);
    await _repository.setShowConfetti(enabled);
  }

  Future<void> toggleCompactView(bool enabled) async {
    state = state.copyWith(compactView: enabled);
    await _repository.setCompactView(enabled);
  }

  Future<void> toggleShowAllDays(bool enabled) async {
    state = state.copyWith(showAllDays: enabled);
    await _repository.setShowAllDays(enabled);
  }

  Future<void> toggleEndOfDayReminder(bool enabled) async {
    state = state.copyWith(endOfDayReminder: enabled);
    await _repository.setEndOfDayReminder(enabled);
    if (enabled) {
      _scheduleEndOfDayReminder();
    } else {
      _cancelEndOfDayReminder();
    }
  }

  Future<void> setEndOfDayReminderTime(TimeOfDay time) async {
    state = state.copyWith(endOfDayReminderTime: time);
    await _repository.setEndOfDayReminderTime(time);
    if (state.endOfDayReminder) {
      _scheduleEndOfDayReminder();
    }
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(hasSeenOnboarding: true);
    await _repository.setHasSeenOnboarding(true);
  }

  void _scheduleEndOfDayReminder() {
    final notificationService = ref.read(notificationServiceProvider);
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      state.endOfDayReminderTime.hour,
      state.endOfDayReminderTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    notificationService.scheduleNotification(
      id: 999, // Unique ID for end-of-day reminder
      title: 'Activity Review',
      body: 'It\'s time to review your daily habits and progress!',
      scheduledDate: scheduledDate,
    );
  }

  void _cancelEndOfDayReminder() {
    final notificationService = ref.read(notificationServiceProvider);
    notificationService.cancelNotification(999);
  }

  Future<void> clearAllData() async {
    await _repository.clearAllData();
    state = AppSettings.defaultSettings();
  }
}
