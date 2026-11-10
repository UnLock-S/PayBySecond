import 'dart:convert';
import '../application/settings.dart';
import '../application/key_value_store.dart';
import 'document_integrity.dart';
import 'profile_lock_stub.dart'
    if (dart.library.js_interop) 'profile_lock_web.dart';

class ProfileRecoveryException implements Exception {
  const ProfileRecoveryException(this.code);
  final String code;
  @override
  String toString() => 'ProfileRecoveryException($code)';
}

/// One v2 commit value plus retained v1/last-known-good copies. Never silently
/// substitute empty settings or erase legacy data when reading/migrating fails.
class RecoverableSettingsRepository implements SettingsRepository {
  RecoverableSettingsRepository(this.store, {DateTime Function()? now})
    : _now = now ?? DateTime.now;
  final KeyValueStore store;
  final DateTime Function() _now;
  static const legacyKey = 'pay_by_second.profile.v1';
  static const profileKey = 'pay_by_second.profile.v2';
  static const originalKey = 'pay_by_second.profile.v1.original';
  static const previousKey = 'pay_by_second.profile.v2.previous';
  static const damagedKey = 'pay_by_second.profile.v2.recovered';
  Future<void> _tail = Future<void>.value();
  Future<T> _locked<T>(Future<T> Function() action) {
    final result = _tail.then((_) => withProfileLock(action));
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  DateTime get _civil => _now().toUtc().add(const Duration(hours: 8));
  ProfileDocument _parse(String raw) => ProfileDocument.fromJson(
    openDocument(raw)['payload'] as Map<String, dynamic>,
  );
  Future<void> _checkLegacy(Map<String, dynamic> envelope) async {
    final expected = envelope['legacyDigest'];
    if (expected == null) return;
    final legacy = await store.read(legacyKey);
    if (legacy == null || textDigest(legacy) != expected) {
      throw const ProfileRecoveryException('legacy-conflict');
    }
  }

  Future<Settings?> _load() async {
    final current = await store.read(profileKey);
    if (current != null) {
      final envelope = openDocument(current);
      await _checkLegacy(envelope);
      return _parse(current).view(_civil);
    }
    final original = await store.read(legacyKey);
    if (original == null) return null;
    final legacy = Settings.fromJson(
      jsonDecode(original) as Map<String, dynamic>,
    );
    final document = ProfileDocument.initial(legacy, _now());
    final sealed = sealedDocument(
      document.toJson(),
      legacyDigest: textDigest(original),
    );
    try {
      if (await store.read(originalKey) == null) {
        await store.write(originalKey, original);
      }
      await store.write(profileKey, sealed);
      final committed = await store.read(profileKey);
      if (committed != sealed) {
        throw const ProfileRecoveryException('migration-readback');
      }
      return document.view(_civil);
    } catch (_) {
      return document.view(_civil, migrationPending: true);
    }
  }

  @override
  Future<Settings?> load() => _locked(_load);
  @override
  Future<void> save(Settings settings) => _locked(() async {
    final raw = await store.read(profileKey);
    if (raw == null) {
      final legacy = await store.read(legacyKey);
      if (legacy != null) {
        final loaded = await _load();
        if (loaded == null || loaded.migrationPending) {
          throw const ProfileRecoveryException('migration-pending');
        }
        final committed = (await store.read(profileKey))!;
        return _commit(
          settings,
          _parse(committed),
          committed,
          openDocument(committed)['legacyDigest'] as String?,
        );
      }
      final next = ProfileDocument.initial(settings, _now());
      final sealed = sealedDocument(next.toJson());
      await store.write(profileKey, sealed);
      if (await store.read(profileKey) != sealed) {
        throw const ProfileRecoveryException('commit-readback');
      }
    } else {
      final envelope = openDocument(raw);
      await _checkLegacy(envelope);
      return _commit(
        settings,
        _parse(raw),
        raw,
        envelope['legacyDigest'] as String?,
      );
    }
  });
  Future<void> _commit(
    Settings settings,
    ProfileDocument current,
    String oldRaw,
    String? legacyDigest,
  ) async {
    final next = current.change(settings, _now());
    final sealed = sealedDocument(next.toJson(), legacyDigest: legacyDigest);
    await store.write(previousKey, oldRaw);
    await store.write(profileKey, sealed);
    if (await store.read(profileKey) != sealed) {
      throw const ProfileRecoveryException('commit-readback');
    }
    await _checkLegacy(openDocument(sealed));
  }

  /// Recovery values remain local and must never be logged or sent to servers.
  Future<Map<String, String>> _copies() async => {
    for (final key in [
      profileKey,
      previousKey,
      legacyKey,
      originalKey,
      damagedKey,
    ])
      if (await store.read(key) case final String value) key: value,
  };
  Future<Map<String, String>> recoveryCopies() => _locked(_copies);
  Future<void> _checkRecovery(String? digest) async {
    if (digest != null &&
        textDigest(canonicalJson(await _copies())) != digest) {
      throw const ProfileRecoveryException('stale-recovery-preview');
    }
  }

  Future<void> restorePrevious({String? expectedDigest}) => _locked(() async {
    await _checkRecovery(expectedDigest);
    final previous = await store.read(previousKey);
    if (previous == null) {
      throw const ProfileRecoveryException('no-recovery-copy');
    }
    _parse(previous);
    await _checkLegacy(openDocument(previous));
    final damaged = await store.read(profileKey);
    if (damaged != null) await store.write(damagedKey, damaged);
    await store.write(profileKey, previous);
  });
  Future<void> restoreLegacy({String? expectedDigest}) => _locked(() async {
    await _checkRecovery(expectedDigest);
    final source = await store.read(legacyKey) ?? await store.read(originalKey);
    if (source == null) throw const ProfileRecoveryException('no-legacy-copy');
    final settings = Settings.fromJson(
      jsonDecode(source) as Map<String, dynamic>,
    );
    final recovered = ProfileDocument.initial(settings, _now());
    final current = await store.read(profileKey);
    if (current != null) await store.write(damagedKey, current);
    final liveLegacy = await store.read(legacyKey);
    await store.write(
      profileKey,
      sealedDocument(
        recovered.toJson(),
        legacyDigest: liveLegacy == null ? null : textDigest(liveLegacy),
      ),
    );
  });
  Future<void> importProfile(ProfileDocument document) => _locked(() async {
    final raw = await store.read(profileKey);
    if (raw != null) await store.write(previousKey, raw);
    final legacy = await store.read(legacyKey);
    await store.write(
      profileKey,
      sealedDocument(
        document.toJson(),
        legacyDigest: legacy == null ? null : textDigest(legacy),
      ),
    );
  });
  @override
  Future<void> clear() => _locked(() async {
    for (final key in [
      profileKey,
      legacyKey,
      originalKey,
      previousKey,
      damagedKey,
    ]) {
      await store.remove(key);
    }
  });
}
