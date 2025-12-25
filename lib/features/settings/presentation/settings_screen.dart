import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'settings_controller.dart';
import '../domain/settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: Navigator.of(context).canPop() 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ) 
          : null,
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            'Appearance',
            [
              _buildSettingTile(
                context,
                title: 'Theme Mode',
                subtitle: _getThemeModeName(settings.themeMode),
                leading: Icons.palette_outlined,
                onTap: () => _showThemeDialog(context, settings.themeMode, controller),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.view_headline_outlined),
                title: const Text('Compact View'),
                subtitle: const Text('Show more habits on the screen'),
                value: settings.compactView,
                onChanged: (value) => controller.toggleCompactView(value),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.celebration_outlined),
                title: const Text('Show Confetti'),
                subtitle: const Text('Celebrate habit completion'),
                value: settings.showConfetti,
                onChanged: (value) => controller.toggleShowConfetti(value),
              ),
            ],
          ),
          _buildSection(
            context,
            'Notifications & Feedback',
            [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('Enable Reminders'),
                subtitle: const Text('Get notified for scheduled habits'),
                value: settings.notificationsEnabled,
                onChanged: (value) => controller.toggleNotifications(value),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.vibration_outlined),
                title: const Text('Haptic Feedback'),
                subtitle: const Text('Vibrate on interactions'),
                value: settings.hapticFeedback,
                onChanged: (value) => controller.toggleHapticFeedback(value),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.nightlight_outlined),
                title: const Text('End-of-day Reminder'),
                subtitle: const Text('Review activities and progress at night'),
                value: settings.endOfDayReminder,
                onChanged: (value) => controller.toggleEndOfDayReminder(value),
              ),
              if (settings.endOfDayReminder)
                _buildSettingTile(
                  context,
                  title: 'Reminder Time',
                  subtitle: settings.endOfDayReminderTime.format(context),
                  leading: Icons.access_time,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: settings.endOfDayReminderTime,
                    );
                    if (time != null) {
                      controller.setEndOfDayReminderTime(time);
                    }
                  },
                ),
            ],
          ),
          _buildSection(
            context,
            'General',
            [
              _buildSettingTile(
                context,
                title: 'First Day of Week',
                subtitle: _getDayName(settings.firstDayOfWeek),
                leading: Icons.calendar_month_outlined,
                onTap: () => _showDayDialog(context, settings.firstDayOfWeek, controller),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.calendar_view_day_outlined),
                title: const Text('Display All Days'),
                subtitle: const Text('Show habits for all days instead of selected day only'),
                value: settings.showAllDays,
                onChanged: (value) => controller.toggleShowAllDays(value),
              ),
            ],
          ),
          _buildSection(
            context,
            'About',
            [
              _buildSettingTile(
                context,
                title: 'App Version',
                subtitle: '1.0.0',
                leading: Icons.info_outline,
              ),
              _buildSettingTile(
                context,
                title: 'Privacy Policy',
                leading: Icons.privacy_tip_outlined,
                onTap: () {
                  // Navigate to Privacy Policy
                },
              ),
            ],
          ),
          _buildSection(
            context,
            'Danger Zone',
            [
              _buildSettingTile(
                context,
                title: 'Clear All Data',
                leading: Icons.delete_forever_outlined,
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () => _showClearDataDialog(context, controller),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData leading,
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(leading, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  void _showClearDataDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your habits, templates, and schedule. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.clearAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  String _getDayName(int day) {
    switch (day) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  void _showThemeDialog(
    BuildContext context,
    ThemeMode currentMode,
    SettingsController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_getThemeModeName(mode)),
              value: mode,
              groupValue: currentMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  controller.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDayDialog(
    BuildContext context,
    int currentDay,
    SettingsController controller,
  ) {
    final days = [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('First Day of Week'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: days.map((day) {
            return RadioListTile<int>(
              title: Text(_getDayName(day)),
              value: day,
              groupValue: currentDay,
              onChanged: (int? value) {
                if (value != null) {
                  controller.setFirstDayOfWeek(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
