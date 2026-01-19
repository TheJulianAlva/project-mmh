import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for SharedPreferences instance.
// This must be overridden in valid scope (e.g. main.dart) or initialized before use.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences provider requires override');
});

// StateNotifier to manage the Last Viewed Period ID
class LastViewedPeriodNotifier extends StateNotifier<int?> {
  final SharedPreferences _prefs;
  static const _key = 'last_viewed_period_id';

  LastViewedPeriodNotifier(this._prefs) : super(null) {
    _load();
  }

  void _load() {
    final val = _prefs.getInt(_key);
    state = val;
  }

  Future<void> setPeriod(int? periodId) async {
    state = periodId;
    if (periodId != null) {
      await _prefs.setInt(_key, periodId);
    } else {
      await _prefs.remove(_key);
    }
  }
}

final lastViewedPeriodIdProvider =
    StateNotifierProvider<LastViewedPeriodNotifier, int?>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return LastViewedPeriodNotifier(prefs);
    });
