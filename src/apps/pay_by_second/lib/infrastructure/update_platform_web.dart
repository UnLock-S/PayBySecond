import 'package:web/web.dart' as web;
import '../application/app_updates.dart';
import 'generated/update_config.dart';

class AppUpdatePlatform implements UpdatePlatform {
  @override
  Future<InstalledApp> installed() async => const InstalledApp(
    version: applicationVersion,
    build: applicationBuild,
    abi: '',
    android: false,
  );
  @override
  Future<bool> open(Uri uri) async {
    // Called synchronously from a user click; keep browser popup blockers happy.
    web.window.open(uri.toString(), '_blank', 'noopener,noreferrer');
    return true;
  }
}
