import 'package:shared_preferences/shared_preferences.dart';
import 'settings_repository.dart';
import 'recoverable_overtime_repository.dart';

class LocalOvertimeRepository extends RecoverableOvertimeRepository {
  LocalOvertimeRepository(SharedPreferencesAsync preferences)
    : super(PreferencesKeyValueStore(preferences));
}
