import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

/// Service that manages local notification scheduling for agenda reminders.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification plugin and timezone data.
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  /// Request permission on Android 13+ (POST_NOTIFICATIONS).
  Future<bool> requestPermission() async {
    final android =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true; // iOS handles via DarwinInitializationSettings
  }

  /// Request exact alarm permission on Android 12+ / 14+.
  Future<bool> requestExactAlarmPermission() async {
    final android =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (android != null) {
      final granted = await android.requestExactAlarmsPermission();
      return granted ?? false;
    }
    return true; // iOS handles via DarwinInitializationSettings
  }

  /// Schedule daily agenda reminder notifications for the next 7 days.
  ///
  /// [hour], [minute]: Time to show the notification each day.
  /// [sessionsByDay]: Map where key is day offset (0=today, 1=tomorrow, etc.)
  ///   and value is the count of sessions on that day.
  /// [enabledScopes]: Which day offsets to include in the summary (0, 1, 2).
  Future<void> scheduleDailyReminders({
    required int hour,
    required int minute,
    required Map<int, int> sessionsByDay,
    required Set<int> enabledScopes,
  }) async {
    // Request exact alarm permission (required on Android 12+/14+)
    await requestExactAlarmPermission();

    // Cancel all existing reminders first
    await cancelAll();

    if (enabledScopes.isEmpty) return;

    final now = tz.TZDateTime.now(tz.local);

    // Schedule one notification per day for the next 7 days
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final scheduleDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + dayOffset,
        hour,
        minute,
      );

      // Skip if the time has already passed today
      if (scheduleDate.isBefore(now)) continue;

      // Build the notification body for THIS day's notification
      final bodyParts = <String>[];
      for (final scope in enabledScopes.toList()..sort()) {
        final actualDay = dayOffset + scope;
        final count = sessionsByDay[actualDay] ?? 0;
        final label = _scopeLabel(scope);
        if (count > 0) {
          bodyParts.add('$label: $count ${count == 1 ? 'cita' : 'citas'}');
        } else {
          bodyParts.add('$label: sin citas');
        }
      }

      final body = bodyParts.join(' · ');
      final title = '📋 Agenda Klinik';

      await _plugin.zonedSchedule(
        100 + dayOffset, // Unique ID per day
        title,
        body,
        scheduleDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'agenda_reminders',
            'Recordatorios de Agenda',
            channelDescription: 'Notificaciones diarias de tu agenda',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null, // One-shot, not repeating
      );
    }
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  String _scopeLabel(int scope) {
    switch (scope) {
      case 0:
        return 'Hoy';
      case 1:
        return 'Mañana';
      case 2:
        return 'Pasado mañana';
      default:
        return 'Día +$scope';
    }
  }

  /// Compute session counts per day for the next 10 days from the repository data.
  /// [allSessions]: List of (fechaInicio ISO8601 string).
  /// Returns a map: day offset from today -> count of sessions.
  Map<int, int> computeSessionCounts(List<String> sessionDates) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final counts = <int, int>{};

    for (final dateStr in sessionDates) {
      try {
        final dt = DateTime.parse(dateStr);
        final sessionDay = DateTime(dt.year, dt.month, dt.day);
        final diff = sessionDay.difference(today).inDays;
        if (diff >= 0 && diff < 10) {
          counts[diff] = (counts[diff] ?? 0) + 1;
        }
      } catch (_) {
        // Skip malformed dates
      }
    }

    return counts;
  }
}
