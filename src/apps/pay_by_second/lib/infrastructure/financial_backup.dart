import 'dart:convert';
import '../application/key_value_store.dart';
import '../application/settings.dart';
import '../application/overtime.dart';
import 'document_integrity.dart';
import 'policy_repository.dart';
import 'recoverable_settings_repository.dart';
import 'profile_lock_stub.dart'
    if (dart.library.js_interop) 'profile_lock_web.dart';

class BackupPreview {
  const BackupPreview(
    this.values,
    this.expectedDigest,
    this.salaryRules,
    this.scheduleRules,
    this.overtimeEntries,
  );
  final Map<String, String?> values;
  final String expectedDigest;
  final int salaryRules, scheduleRules, overtimeEntries;
}

/// Bounded plaintext backup, all financial keys, with a recoverable write-ahead
/// journal. Recovery completes before repositories read any imported data.
class FinancialBackup {
  FinancialBackup(this.store);
  final KeyValueStore store;
  static const journalKey = 'pay_by_second.import.journal.v1';
  static const previousImportKey = 'pay_by_second.import.previous.v1';
  static const keys = [
    RecoverableSettingsRepository.profileKey,
    RecoverableSettingsRepository.legacyKey,
    RecoverableSettingsRepository.originalKey,
    RecoverableSettingsRepository.previousKey,
    RecoverableSettingsRepository.damagedKey,
    'pay_by_second.overtime.v1',
    'pay_by_second.overtime.v2',
    'pay_by_second.overtime.v2.previous',
    'pay_by_second.policy.v1',
    'pay_by_second.policy.v1.previous',
  ];
  Future<Map<String, String?>> _read() async => {
    for (final key in keys) key: await store.read(key),
  };
  Future<void> _write(Map<String, String?> values) async {
    for (final key in keys) {
      final value = values[key];
      if (value == null) {
        await store.remove(key);
      } else {
        await store.write(key, value);
      }
      if (await store.read(key) != value) {
        throw StateError('Backup readback failed');
      }
    }
  }

  Future<void> _recover() async {
    final raw = await store.read(journalKey);
    if (raw == null) return;
    final original = Map<String, String?>.from(
      openDocument(raw)['payload'] as Map,
    );
    if (original.length != keys.length ||
        original.keys.any((key) => !keys.contains(key))) {
      throw const FormatException('Invalid recovery journal');
    }
    await _write(original);
    await store.remove(journalKey);
  }

  Future<void> recoverInterruptedImport() => withProfileLock(_recover);
  Future<void> clearRecoveryCopies() => withProfileLock(() async {
    await store.remove(previousImportKey);
    await store.remove(journalKey);
  });
  Future<BackupPreview> previewPreviousImport() => withProfileLock(() async {
    await _recover();
    final raw = await store.read(previousImportKey);
    if (raw == null) throw StateError('No previous import');
    return _preview(
      sealedDocument({
        'schemaVersion': 1,
        'kind': 'pay-by-second-financial-backup',
        'values': openDocument(raw)['payload'],
      }),
    );
  });
  Future<String> export() => withProfileLock(() async {
    await _recover();
    return sealedDocument({
      'schemaVersion': 1,
      'kind': 'pay-by-second-financial-backup',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'values': await _read(),
    });
  });
  Future<BackupPreview> preview(String text) =>
      withProfileLock(() => _preview(text));
  Future<BackupPreview> _preview(String text) async {
    await _recover();
    final payload = openDocument(text)['payload'] as Map<String, dynamic>;
    if (payload['schemaVersion'] != 1 ||
        payload['kind'] != 'pay-by-second-financial-backup') {
      throw const FormatException('Unsupported backup');
    }
    final values = Map<String, String?>.from(payload['values'] as Map);
    if (values.keys.any((k) => !keys.contains(k)) ||
        values.length != keys.length) {
      throw const FormatException('Unknown or missing backup keys');
    }
    var pay = 0, work = 0, entries = 0;
    final profile = values[RecoverableSettingsRepository.profileKey];
    if (profile != null) {
      final envelope = openDocument(profile);
      final doc = ProfileDocument.fromJson(
        envelope['payload'] as Map<String, dynamic>,
      );
      pay = doc.salaries.length;
      work = doc.schedules.length;
      final hash = envelope['legacyDigest'];
      if (hash != null &&
          hash !=
              textDigest(
                values[RecoverableSettingsRepository.legacyKey] ?? '',
              )) {
        throw const FormatException('Legacy backup conflict');
      }
    } else if (values[RecoverableSettingsRepository.legacyKey]
        case final String raw) {
      Settings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      pay = 1;
      work = 1;
    }
    if (values['pay_by_second.overtime.v1'] case final String raw) {
      final book = OvertimeBook.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      entries = book.entries.length + (book.active == null ? 0 : 1);
    }
    if (values['pay_by_second.overtime.v2'] case final String raw) {
      final envelope = openDocument(raw);
      final book = OvertimeBook.fromJson(
        envelope['payload'] as Map<String, dynamic>,
      );
      final hash = envelope['legacyDigest'];
      if (hash != null &&
          hash != textDigest(values['pay_by_second.overtime.v1'] ?? '')) {
        throw const FormatException('Legacy overtime conflict');
      }
      entries = book.entries.length + (book.active == null ? 0 : 1);
    }
    for (final key in [
      'pay_by_second.policy.v1',
      'pay_by_second.policy.v1.previous',
    ]) {
      if (values[key] case final String raw) {
        PolicyRepository(store).decode(raw);
      }
    }
    return BackupPreview(
      Map.unmodifiable(values),
      textDigest(canonicalJson(await _read())),
      pay,
      work,
      entries,
    );
  }

  Future<void> apply(BackupPreview preview) => withProfileLock(() async {
    await _recover();
    await _preview(
      sealedDocument({
        'schemaVersion': 1,
        'kind': 'pay-by-second-financial-backup',
        'values': preview.values,
      }),
    );
    final before = await _read();
    if (textDigest(canonicalJson(before)) != preview.expectedDigest) {
      throw StateError('Data changed after preview');
    }
    await store.write(previousImportKey, sealedDocument(before));
    await store.write(journalKey, sealedDocument(before));
    try {
      await _write(preview.values);
      await store.remove(journalKey);
    } catch (_) {
      await _recover();
      rethrow;
    }
  });
}
