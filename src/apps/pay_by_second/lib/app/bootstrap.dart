import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../infrastructure/settings_repository.dart';
import '../infrastructure/system_clock.dart';
import 'app.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    PayBySecondApp(
      repository: LocalSettingsRepository(SharedPreferencesAsync()),
      clock: SystemClock(),
    ),
  );
}
