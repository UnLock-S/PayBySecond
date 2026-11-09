import 'package:shared_preferences/shared_preferences.dart';
import '../application/language_repository.dart';

class LocalLanguageRepository implements LanguageRepository {
  LocalLanguageRepository(this.preferences);
  final SharedPreferencesAsync preferences;
  static const _key = 'pay_by_second.language.v1';
  @override
  Future<String?> load() => preferences.getString(_key);
  @override
  Future<void> save(String language) => preferences.setString(_key, language);
}
