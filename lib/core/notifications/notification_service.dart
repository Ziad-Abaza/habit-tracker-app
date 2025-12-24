import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

part 'notification_service.g.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    // Set the local timezone explicitly with fallback
    try {
      final String timeZoneName = DateTime.now().timeZoneName;
      print('Device timezone: $timeZoneName');
      
      // Try to get location, fallback to common timezones if not found
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        print('Timezone $timeZoneName not found, trying alternatives...');
        // Common fallbacks based on offset
        final offset = DateTime.now().timeZoneOffset;
        if (offset.inHours == 2) {
          tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
        } else {
          tz.setLocalLocation(tz.getLocation('UTC'));
        }
      }
      
      print('Using timezone: ${tz.local.name}');
    } catch (e) {
      print('Error setting timezone: $e');
      // Default to UTC if all else fails
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(initializationSettings);
    
    // Request permissions for Android 13+
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImpl != null) {
      final notificationPermission = await androidImpl.requestNotificationsPermission();
      print('Notification permission granted: $notificationPermission');
      
      final exactAlarmPermission = await androidImpl.requestExactAlarmsPermission();
      print('Exact alarm permission granted: $exactAlarmPermission');
      
      // Check if exact alarms are allowed
      final canScheduleExactAlarms = await androidImpl.canScheduleExactNotifications();
      print('Can schedule exact alarms: $canScheduleExactAlarms');
      
      if (canScheduleExactAlarms == false) {
        print('WARNING: Exact alarms not allowed! Notifications may not work.');
        print('Please enable "Alarms & reminders" permission in app settings.');
      }
    }
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_channel',
          'Habit Notifications',
          channelDescription: 'Notifications for habits and schedule',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      // Cancel any existing notification with this ID first
      await _notificationsPlugin.cancel(id);
      
      // Create TZDateTime directly in local timezone to avoid UTC conversion issues
      final tzScheduledDate = tz.TZDateTime(
        tz.local,
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        scheduledDate.hour,
        scheduledDate.minute,
        scheduledDate.second,
      );
      
      final now = tz.TZDateTime.now(tz.local);
      final timeUntil = tzScheduledDate.difference(now);
      
      // Debug log
      print('═══════════════════════════════════════');
      print('📅 Scheduling notification:');
      print('   Title: $title');
      print('   ID: $id');
      print('   Current time: $now');
      print('   Scheduled for: $tzScheduledDate');
      print('   Time until: ${timeUntil.inMinutes}m ${timeUntil.inSeconds % 60}s');
      print('═══════════════════════════════════════');
      
      if (tzScheduledDate.isBefore(now)) {
        print('⚠️  WARNING: Scheduled time is in the past! Notification will not trigger.');
        return;
      }
      
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_channel',
            'Habit Notifications',
            channelDescription: 'Notifications for habits and schedule',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      print('✅ Notification scheduled successfully!');
      
    } catch (e, stackTrace) {
      print('❌ Error scheduling notification: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}

@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationService();
}
