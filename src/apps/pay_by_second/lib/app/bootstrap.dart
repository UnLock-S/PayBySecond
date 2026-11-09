import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../infrastructure/settings_repository.dart';
import '../infrastructure/system_clock.dart';
import 'app.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'PayBySecond Sans (Noto Sans SC subset)',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
  runApp(
    PayBySecondApp(
      repository: LocalSettingsRepository(SharedPreferencesAsync()),
      clock: SystemClock(),
    ),
  );
}
