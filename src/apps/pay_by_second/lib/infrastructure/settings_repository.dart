import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../application/settings.dart';

class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this.preferences);
  final SharedPreferencesAsync preferences;
  static const _key = 'pay_by_second.profile.v1';
  @override
  Future<Settings?> load() async {
    final value = await preferences.getString(_key);
    return value == null
        ? null
        : Settings.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  @override
  Future<void> save(Settings settings) =>
      preferences.setString(_key, jsonEncode(settings.toJson()));
  @override
  Future<void> clear() => preferences.remove(_key);
}
