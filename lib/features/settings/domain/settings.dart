import 'package:flutter/material.dart';

class AppSettings {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final int firstDayOfWeek;
  final bool hapticFeedback;
  final bool showConfetti;
  final bool compactView;
  final bool showAllDays;
  final bool endOfDayReminder;
  final TimeOfDay endOfDayReminderTime;
  final bool hasSeenOnboarding;

  const AppSettings({
    required this.themeMode,
    required this.notificationsEnabled,
    required this.firstDayOfWeek,
    required this.hapticFeedback,
    required this.showConfetti,
    required this.compactView,
    required this.showAllDays,
    required this.endOfDayReminder,
    required this.endOfDayReminderTime,
    required this.hasSeenOnboarding,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    int? firstDayOfWeek,
    bool? hapticFeedback,
    bool? showConfetti,
    bool? compactView,
    bool? showAllDays,
    bool? endOfDayReminder,
    TimeOfDay? endOfDayReminderTime,
    bool? hasSeenOnboarding,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      showConfetti: showConfetti ?? this.showConfetti,
      compactView: compactView ?? this.compactView,
      showAllDays: showAllDays ?? this.showAllDays,
      endOfDayReminder: endOfDayReminder ?? this.endOfDayReminder,
      endOfDayReminderTime: endOfDayReminderTime ?? this.endOfDayReminderTime,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }

  factory AppSettings.defaultSettings() {
    return const AppSettings(
      themeMode: ThemeMode.system,
      notificationsEnabled: true,
      firstDayOfWeek: DateTime.monday,
      hapticFeedback: true,
      showConfetti: true,
      compactView: false,
      showAllDays: false,
      endOfDayReminder: false,
      endOfDayReminderTime: const TimeOfDay(hour: 21, minute: 0),
      hasSeenOnboarding: false,
    );
  }
}
