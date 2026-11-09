import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../application/app_updates.dart';
import 'generated/update_config.dart';

class AppUpdatePlatform implements UpdatePlatform {
  static const channel = MethodChannel('cn.paybysecond/app_updates');
  @override
  Future<InstalledApp> installed() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const InstalledApp(
        version: applicationVersion,
        build: applicationBuild,
        abi: '',
        android: false,
      );
    }
    final info = await channel.invokeMapMethod<String, dynamic>('appInfo');
    if (info == null) {
      throw const FormatException('Missing installed package info');
    }
    return InstalledApp(
      version: info['version'] as String,
      build: info['build'] as String,
      abi: info['abi'] as String,
      android: true,
    );
  }

  @override
  Future<bool> open(Uri uri) async =>
      await channel.invokeMethod<bool>('openRelease', uri.toString()) ?? false;
}
