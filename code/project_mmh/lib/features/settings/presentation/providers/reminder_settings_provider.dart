import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_mmh/features/core/presentation/providers/preferences_provider.dart';
import 'package:project_mmh/core/services/notification_service.dart';
import 'package:project_mmh/features/agenda/data/repositories/agenda_repository.dart';

/// State model for reminder settings.
class ReminderSettings {
  final bool enabled;
  final int hour;
  final int minute;
  final bool summaryToday;
  final bool summaryTomorrow;
  final bool summaryDayAfter;

  const ReminderSettings({
    this.enabled = false,
    this.hour = 7,
    this.minute = 0,
    this.summaryToday = true,
    this.summaryTomorrow = false,
    this.summaryDayAfter = false,
  });

  ReminderSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    bool? summaryToday,
    bool? summaryTomorrow,
    bool? summaryDayAfter,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      summaryToday: summaryToday ?? this.summaryToday,
      summaryTomorrow: summaryTomorrow ?? this.summaryTomorrow,
      summaryDayAfter: summaryDayAfter ?? this.summaryDayAfter,
    );
  }

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  Set<int> get enabledScopes {
    final scopes = <int>{};
    if (summaryToday) scopes.add(0);
    if (summaryTomorrow) scopes.add(1);
    if (summaryDayAfter) scopes.add(2);
    return scopes;
  }
}

/// Notifier that persists reminder settings to SharedPreferences
/// and triggers notification scheduling when settings change.
class ReminderSettingsNotifier extends StateNotifier<ReminderSettings> {
  final SharedPreferences _prefs;

  static const _keyEnabled = 'reminder_enabled';
  static const _keyHour = 'reminder_hour';
  static const _keyMinute = 'reminder_minute';
  static const _keySummaryToday = 'reminder_summary_today';
  static const _keySummaryTomorrow = 'reminder_summary_tomorrow';
  static const _keySummaryDayAfter = 'reminder_summary_day_after';

  ReminderSettingsNotifier(this._prefs) : super(const ReminderSettings()) {
    _load();
  }

  void _load() {
    state = ReminderSettings(
      enabled: _prefs.getBool(_keyEnabled) ?? false,
      hour: _prefs.getInt(_keyHour) ?? 7,
      minute: _prefs.getInt(_keyMinute) ?? 0,
      summaryToday: _prefs.getBool(_keySummaryToday) ?? true,
      summaryTomorrow: _prefs.getBool(_keySummaryTomorrow) ?? false,
      summaryDayAfter: _prefs.getBool(_keySummaryDayAfter) ?? false,
    );
  }

  Future<void> _save() async {
    await _prefs.setBool(_keyEnabled, state.enabled);
    await _prefs.setInt(_keyHour, state.hour);
    await _prefs.setInt(_keyMinute, state.minute);
    await _prefs.setBool(_keySummaryToday, state.summaryToday);
    await _prefs.setBool(_keySummaryTomorrow, state.summaryTomorrow);
    await _prefs.setBool(_keySummaryDayAfter, state.summaryDayAfter);
  }

  Future<void> setEnabled(bool value) async {
    if (value) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) return;
    }
    state = state.copyWith(enabled: value);
    await _save();
    if (!value) {
      await NotificationService.instance.cancelAll();
    }
  }

  Future<void> setTime(int hour, int minute) async {
    state = state.copyWith(hour: hour, minute: minute);
    await _save();
  }

  Future<void> setSummaryToday(bool value) async {
    state = state.copyWith(summaryToday: value);
    await _save();
  }

  Future<void> setSummaryTomorrow(bool value) async {
    state = state.copyWith(summaryTomorrow: value);
    await _save();
  }

  Future<void> setSummaryDayAfter(bool value) async {
    state = state.copyWith(summaryDayAfter: value);
    await _save();
  }

  /// Refresh scheduled notifications based on current settings and agenda data.
  Future<void> refreshNotifications() async {
    if (!state.enabled || state.enabledScopes.isEmpty) {
      await NotificationService.instance.cancelAll();
      return;
    }

    final repo = AgendaRepository();

    // Get sessions for the next 10 days
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 10));

    final sessions = await repo.getSesionesByDateRange(
      start.toIso8601String(),
      end.toIso8601String(),
    );

    final dates = sessions.map((s) => s.fechaInicio).toList();
    final counts = NotificationService.instance.computeSessionCounts(dates);

    await NotificationService.instance.scheduleDailyReminders(
      hour: state.hour,
      minute: state.minute,
      sessionsByDay: counts,
      enabledScopes: state.enabledScopes,
    );
  }
}

/// Provider for reminder settings.
final reminderSettingsProvider =
    StateNotifierProvider<ReminderSettingsNotifier, ReminderSettings>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return ReminderSettingsNotifier(prefs);
    });
