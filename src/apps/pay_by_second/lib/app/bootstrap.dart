import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../infrastructure/settings_repository.dart';
import '../infrastructure/overtime_repository.dart';
import '../infrastructure/system_clock.dart';
import '../infrastructure/language_repository.dart';
import 'app.dart';
import '../infrastructure/create_updater.dart';
import '../infrastructure/financial_backup.dart';
import '../infrastructure/policy_repository.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'PayBySecond Sans (Noto Sans SC subset)',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
    yield LicenseEntryWithLineBreaks([
      'PayBySecond Sans JP (Noto Sans JP subset)',
    ], await rootBundle.loadString('assets/fonts/OFL-JP.txt'));
  });
  runApp(
    PayBySecondApp(
      repository: LocalSettingsRepository(SharedPreferencesAsync()),
      backup: FinancialBackup(
        PreferencesKeyValueStore(SharedPreferencesAsync()),
      ),
      policyRepository: PolicyRepository(
        PreferencesKeyValueStore(SharedPreferencesAsync()),
      ),
      appearanceStore: PreferencesKeyValueStore(SharedPreferencesAsync()),
      clock: SystemClock(),
      updates: createUpdater(),
      overtimeRepository: LocalOvertimeRepository(SharedPreferencesAsync()),
      languageRepository: LocalLanguageRepository(SharedPreferencesAsync()),
    ),
  );
}
