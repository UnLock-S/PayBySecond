import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../application/app_updates.dart';

class LocalUpdatePreferences implements UpdatePreferences {
  LocalUpdatePreferences(this.preferences);
  final SharedPreferencesAsync preferences;
  static const key = 'pay_by_second.updates.v1';
  @override
  Future<UpdateCache> load() async {
    final value = await preferences.getString(key);
    return value == null
        ? const UpdateCache()
        : UpdateCache.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  @override
  Future<void> save(UpdateCache cache) =>
      preferences.setString(key, jsonEncode(cache.toJson()));
}
