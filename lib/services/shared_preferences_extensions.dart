import 'package:shared_preferences/shared_preferences.dart';

extension SharedPreferencesExtensions on SharedPreferences {
  Future<void> setDateTime(String key, DateTime value) async {
    await setString(key, value.toIso8601String());
  }

  DateTime? getDateTime(String key) {
    final value = getString(key);
    return value != null ? DateTime.parse(value) : null;
  }
}