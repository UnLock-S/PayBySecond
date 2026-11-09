import 'package:shared_preferences/shared_preferences.dart';
import '../application/app_updates.dart';
import 'generated/update_config.dart';
import 'release_transport_stub.dart'
    if (dart.library.io) 'release_transport_io.dart';
import 'update_platform.dart';
import 'update_preferences.dart';

UpdateController createUpdater() => UpdateController(
  source: ReleaseSource(updateRepository),
  transport: GitHubReleaseTransport(),
  preferences: LocalUpdatePreferences(SharedPreferencesAsync()),
  platform: AppUpdatePlatform(),
);
