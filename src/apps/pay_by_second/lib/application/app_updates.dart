import 'package:flutter/foundation.dart';

class AppVersion implements Comparable<AppVersion> {
  AppVersion._(this.major, this.minor, this.patch);
  final int major, minor, patch;
  static AppVersion? parse(String text) {
    final m = RegExp(
      r'^v?(0|[1-9]\d{0,8})\.(0|[1-9]\d{0,8})\.(0|[1-9]\d{0,8})(?:\+\d{1,9})?$',
    ).firstMatch(text);
    return m == null
        ? null
        : AppVersion._(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
  }

  @override
  int compareTo(AppVersion other) {
    for (final value in [
      major.compareTo(other.major),
      minor.compareTo(other.minor),
      patch.compareTo(other.patch),
    ]) {
      if (value != 0) return value;
    }
    return 0;
  }

  @override
  String toString() => '$major.$minor.$patch';
}

class ReleaseSource {
  ReleaseSource(this.repository) {
    if (!RegExp(
      r'^[A-Za-z0-9][A-Za-z0-9_.-]{0,98}/[A-Za-z0-9][A-Za-z0-9_.-]{0,99}$',
    ).hasMatch(repository)) {
      throw ArgumentError('Expected GitHub owner/repository');
    }
  }
  final String repository;
  Uri get endpoint =>
      Uri.https('api.github.com', '/repos/$repository/releases/latest');
  Uri get releases => Uri.https('github.com', '/$repository/releases');
  Uri release(String tag) => Uri(
    scheme: 'https',
    host: 'github.com',
    pathSegments: [...repository.split('/'), 'releases', 'tag', tag],
  );
  bool allows(Uri uri) {
    final parts = uri.pathSegments,
        prefix = repository.toLowerCase().split('/');
    return uri.scheme == 'https' &&
        uri.host == 'github.com' &&
        uri.port == 443 &&
        uri.userInfo.isEmpty &&
        !uri.hasQuery &&
        !uri.hasFragment &&
        parts.length >= 3 &&
        parts[0].toLowerCase() == prefix[0] &&
        parts[1].toLowerCase() == prefix[1] &&
        parts[2] == 'releases';
  }
}

class ReleaseInfo {
  ReleaseInfo._({
    required this.version,
    required this.tag,
    required this.notes,
    required this.page,
    required this.apk,
    required this.assetName,
    required this.sha256,
  });
  final AppVersion version;
  final String tag, notes;
  final Uri page;
  final Uri? apk;
  final String? assetName, sha256;
  factory ReleaseInfo.fromJson(
    Map<String, dynamic> json,
    ReleaseSource source,
    String abi,
  ) {
    final tag = json['tag_name'];
    if (tag is! String || json['assets'] is! List) {
      throw const FormatException('Release tag and asset list required');
    }
    final version = AppVersion.parse(tag);
    if (version == null ||
        json['draft'] != false ||
        json['prerelease'] != false) {
      throw const FormatException('Stable semantic version required');
    }
    final body = json['body'];
    final notes = body is String
        ? body.substring(0, body.length > 12000 ? 12000 : body.length)
        : '';
    Map<String, dynamic>? selected;
    for (final target in [abi, 'universal']) {
      for (final raw in json['assets'] as List) {
        if (raw is! Map<String, dynamic>) continue;
        final name = raw['name'], url = raw['browser_download_url'];
        if (name is! String ||
            url is! String ||
            raw['state'] != 'uploaded' ||
            raw['size'] is! int ||
            (raw['size'] as int) <= 0) {
          continue;
        }
        final expression = RegExp(
          '^PayBySecond-${RegExp.escape(version.toString())}-${RegExp.escape(target)}(?:-test)?\\.apk\$',
        );
        final uri = Uri.tryParse(url);
        if (!expression.hasMatch(name) || uri == null || !source.allows(uri)) {
          continue;
        }
        final parts = uri.pathSegments;
        if (parts.length != 6 ||
            parts[3] != 'download' ||
            parts[4] != tag ||
            parts[5] != name) {
          continue;
        }
        // Ambiguous duplicates are treated as invalid release metadata.
        if (selected != null) {
          throw const FormatException('Duplicate APK assets');
        }
        selected = raw;
      }
      if (selected != null) break;
    }
    final digest = selected?['digest'];
    return ReleaseInfo._(
      version: version,
      tag: tag,
      notes: notes,
      page: source.release(tag),
      apk: selected == null
          ? null
          : Uri.parse(selected['browser_download_url'] as String),
      assetName: selected?['name'] as String?,
      sha256:
          digest is String &&
              RegExp(r'^sha256:[0-9a-fA-F]{64}$').hasMatch(digest)
          ? digest.substring(7)
          : null,
    );
  }
}

class InstalledApp {
  const InstalledApp({
    required this.version,
    required this.build,
    required this.abi,
    required this.android,
  });
  final String version, build, abi;
  final bool android;
}

abstract interface class UpdatePlatform {
  Future<InstalledApp> installed();
  Future<bool> open(Uri uri);
}

class DisabledUpdatePlatform implements UpdatePlatform {
  const DisabledUpdatePlatform();
  @override
  Future<InstalledApp> installed() async =>
      const InstalledApp(version: '0.0.0', build: '0', abi: '', android: false);
  @override
  Future<bool> open(Uri uri) async => false;
}

class ReleaseResponse {
  const ReleaseResponse(this.status, {this.json, this.etag});
  final int status;
  final Map<String, dynamic>? json;
  final String? etag;
}

abstract interface class ReleaseTransport {
  Future<ReleaseResponse> fetch(Uri endpoint, {String? etag});
}

class UpdateCache {
  const UpdateCache({
    this.automatic = true,
    this.repository = '',
    this.attemptedAt,
    this.checkedAt,
    this.release,
    this.etag,
    this.noRelease = false,
  });
  final bool automatic, noRelease;
  final String repository;
  final DateTime? attemptedAt, checkedAt;
  final Map<String, dynamic>? release;
  final String? etag;
  Map<String, dynamic> toJson() => {
    'version': 1,
    'automatic': automatic,
    'repository': repository,
    'attemptedAt': attemptedAt?.toIso8601String(),
    'checkedAt': checkedAt?.toIso8601String(),
    'release': release,
    'etag': etag,
    'noRelease': noRelease,
  };
  factory UpdateCache.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1) {
      throw const FormatException('Unknown update cache');
    }
    DateTime? date(Object? value) {
      if (value == null) return null;
      final result = DateTime.parse(value as String);
      if (!result.isUtc) throw const FormatException('UTC time required');
      return result;
    }

    return UpdateCache(
      automatic: json['automatic'] as bool,
      repository: json['repository'] as String,
      attemptedAt: date(json['attemptedAt']),
      checkedAt: date(json['checkedAt']),
      release: json['release'] as Map<String, dynamic>?,
      etag: json['etag'] as String?,
      noRelease: json['noRelease'] as bool,
    );
  }
}

abstract interface class UpdatePreferences {
  Future<UpdateCache> load();
  Future<void> save(UpdateCache cache);
}

class MemoryUpdatePreferences implements UpdatePreferences {
  UpdateCache value = const UpdateCache();
  @override
  Future<UpdateCache> load() async => value;
  @override
  Future<void> save(UpdateCache cache) async => value = cache;
}

enum UpdateStatus {
  idle,
  checking,
  available,
  current,
  noRelease,
  offline,
  rateLimited,
  invalid,
  storageError,
  unsupported,
}

/// No timers, background tasks or profile access. At most one startup request
/// per 24 hours, plus explicit manual checks with a 30-second local cooldown.
class UpdateController extends ChangeNotifier {
  UpdateController({
    required this.source,
    required this.transport,
    required this.preferences,
    required this.platform,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;
  final ReleaseSource source;
  final ReleaseTransport transport;
  final UpdatePreferences preferences;
  final UpdatePlatform platform;
  final DateTime Function() _now;
  UpdateCache cache = const UpdateCache();
  InstalledApp? installed;
  ReleaseInfo? latest;
  UpdateStatus status = UpdateStatus.idle;
  bool ready = false, saving = false, _disposed = false, _initializing = false;
  bool get busy => status == UpdateStatus.checking || saving;
  bool get available =>
      latest != null &&
      installed != null &&
      installed!.android &&
      AppVersion.parse(installed!.version) != null &&
      latest!.version.compareTo(AppVersion.parse(installed!.version)!) > 0;
  bool get canCheck => ready && installed?.android == true && !busy;
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> initialize() async {
    if (_initializing || ready || _disposed) return;
    _initializing = true;
    try {
      installed = await platform.installed();
      cache = await preferences.load();
      if (cache.repository != source.repository) {
        cache = UpdateCache(
          automatic: cache.automatic,
          repository: source.repository,
        );
      }
      if (AppVersion.parse(installed!.version) == null) {
        throw const FormatException('Invalid installed version');
      }
      if (cache.release != null) {
        latest = ReleaseInfo.fromJson(cache.release!, source, installed!.abi);
      }
      ready = true;
      status = !installed!.android
          ? UpdateStatus.unsupported
          : latest != null
          ? (available ? UpdateStatus.available : UpdateStatus.current)
          : cache.noRelease
          ? UpdateStatus.noRelease
          : UpdateStatus.idle;
      notifyListeners();
      if (cache.automatic && installed!.android) await check(automatic: true);
    } catch (_) {
      ready = installed != null;
      status = UpdateStatus.storageError;
      notifyListeners();
    } finally {
      _initializing = false;
    }
  }

  Future<void> setAutomatic(bool enabled) async {
    if (!ready || busy) return;
    saving = true;
    notifyListeners();
    try {
      final next = UpdateCache(
        automatic: enabled,
        repository: source.repository,
        attemptedAt: cache.attemptedAt,
        checkedAt: cache.checkedAt,
        release: cache.release,
        etag: cache.etag,
        noRelease: cache.noRelease,
      );
      await preferences.save(next);
      cache = next;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> check({bool automatic = false}) async {
    if (!canCheck || _disposed) return;
    final now = _now().toUtc(), previous = cache.attemptedAt;
    if (previous != null &&
        !now.isBefore(previous) &&
        now.difference(previous) <
            (automatic
                ? const Duration(hours: 24)
                : const Duration(seconds: 30))) {
      return;
    }
    status = UpdateStatus.checking;
    notifyListeners();
    final attempted = UpdateCache(
      automatic: cache.automatic,
      repository: source.repository,
      attemptedAt: now,
      checkedAt: cache.checkedAt,
      release: cache.release,
      etag: cache.etag,
      noRelease: cache.noRelease,
    );
    try {
      await preferences.save(attempted);
      cache = attempted;
    } catch (_) {
      status = UpdateStatus.storageError;
      notifyListeners();
      return;
    }
    try {
      final response = await transport.fetch(
        source.endpoint,
        etag: cache.release == null ? null : cache.etag,
      );
      if (_disposed) return;
      if (response.status == 403 || response.status == 429) {
        status = UpdateStatus.rateLimited;
        return;
      }
      if (response.status != 200 &&
          response.status != 304 &&
          response.status != 404) {
        status = UpdateStatus.offline;
        return;
      }
      final json = response.status == 304 ? cache.release : response.json;
      if (response.status == 304 && json == null) {
        throw const FormatException('304 without cached data');
      }
      final release = response.status == 404
          ? null
          : ReleaseInfo.fromJson(json!, source, installed!.abi);
      final next = UpdateCache(
        automatic: cache.automatic,
        repository: source.repository,
        attemptedAt: now,
        checkedAt: _now().toUtc(),
        release: response.status == 404 ? null : json,
        etag: response.status == 304 ? cache.etag : response.etag,
        noRelease: response.status == 404,
      );
      try {
        await preferences.save(next);
      } catch (_) {
        status = UpdateStatus.storageError;
        return;
      }
      cache = next;
      latest = release;
      status = release == null
          ? UpdateStatus.noRelease
          : available
          ? UpdateStatus.available
          : UpdateStatus.current;
    } on FormatException {
      status = UpdateStatus.invalid;
    } catch (_) {
      status = UpdateStatus.offline;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> open(Uri uri) async {
    if (!source.allows(uri)) return false;
    try {
      return await platform.open(uri);
    } catch (_) {
      return false;
    }
  }
}
