import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io' show Platform;

/// Abstraction for notifications to enable DI and testing.
abstract class NotificationService {
  Future<void> initialize();
  Future<void> requestPermissions();
  Future<void> scheduleDailyMessages({
    required String morningText,
    required String afternoonText,
    required String eveningText,
    required String nightText,
    Map<String, String>? times,
  });
  Future<void> cancelAllNotifications();
  Future<void> showInstantNotification(String title, String body);
}

/// Production implementation backed by flutter_local_notifications + timezone.
class LocalNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    try {
      final String localName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (e) {
      if (kDebugMode) debugPrint('Timezone fallback due to: $e');
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _notifications.initialize(initSettings);
    await requestPermissions();
  }

  @override
  Future<void> requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      if (granted != true) {
        debugPrint('Notification permissions denied');
        return;
      }
      await androidPlugin.requestExactAlarmsPermission();
    }

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  @override
  Future<void> scheduleDailyMessages({
    required String morningText,
    required String afternoonText,
    required String eveningText,
    required String nightText,
    Map<String, String>? times,
  }) async {
    await cancelAllNotifications();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'love_garden_daily',
        'Daily Messages',
        channelDescription: 'Daily love messages by time periods',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Helpers extracted to reduce complexity
    int parseHour(String hhmm, int fallback) {
      try {
        final parts = hhmm.split(':');
        return int.parse(parts[0]);
      } catch (_) {
        return fallback;
      }
    }

    int parseMinute(String hhmm, int fallback) {
      try {
        final parts = hhmm.split(':');
        return int.parse(parts[1]);
      } catch (_) {
        return fallback;
      }
    }

    Future<void> scheduleDailyOnce(
      int id,
      int hour,
      int minute,
      String body,
    ) async {
      if (Platform.isLinux) {
        // Linux plugin doesn't implement zonedSchedule; skip scheduling to avoid crash.
        if (kDebugMode) {
          debugPrint('[Notifications] Linux detected: scheduled notifications are not supported by flutter_local_notifications on Linux. Skipping scheduling for id=$id at $hour:${minute.toString().padLeft(2, '0')}');
        }
        return;
      }

      final nowTz = tz.TZDateTime.now(tz.local);
      var whenTz = tz.TZDateTime(
        tz.local,
        nowTz.year,
        nowTz.month,
        nowTz.day,
        hour,
        minute,
      );
      if (whenTz.isBefore(nowTz)) whenTz = whenTz.add(const Duration(days: 1));
      await _notifications.zonedSchedule(
        id,
        'Love Garden 💌',
        body,
        whenTz,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    final morningTime = times?['mañana'] ?? '08:30';
    final afternoonTime = times?['tarde'] ?? '13:00';
    final eveningTime = times?['noche'] ?? '20:30';
    final nightTime = times?['madrugada'] ?? '23:30';

    await scheduleDailyOnce(
      100,
      parseHour(morningTime, 8),
      parseMinute(morningTime, 30),
      morningText,
    );
    await scheduleDailyOnce(
      101,
      parseHour(afternoonTime, 13),
      parseMinute(afternoonTime, 0),
      afternoonText,
    );
    await scheduleDailyOnce(
      102,
      parseHour(eveningTime, 20),
      parseMinute(eveningTime, 30),
      eveningText,
    );
    await scheduleDailyOnce(
      103,
      parseHour(nightTime, 23),
      parseMinute(nightTime, 30),
      nightText,
    );
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  @override
  Future<void> showInstantNotification(String title, String body) async {
    await _notifications.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'love_garden_instant',
          'Instant Notifications',
          channelDescription: 'Immediate notifications from Love Garden',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
