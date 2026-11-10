import 'package:shared_preferences/shared_preferences.dart';
import '../application/key_value_store.dart';
import 'recoverable_settings_repository.dart';

class PreferencesKeyValueStore implements KeyValueStore {
  PreferencesKeyValueStore(this.preferences);
  final SharedPreferencesAsync preferences;
  @override
  Future<String?> read(String key) => preferences.getString(key);
  @override
  Future<void> write(String key, String value) =>
      preferences.setString(key, value);
  @override
  Future<void> remove(String key) => preferences.remove(key);
}

class LocalSettingsRepository extends RecoverableSettingsRepository {
  LocalSettingsRepository(SharedPreferencesAsync preferences, {super.now})
    : super(PreferencesKeyValueStore(preferences));
}
