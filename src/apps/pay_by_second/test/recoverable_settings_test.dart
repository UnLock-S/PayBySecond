import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_by_second/application/key_value_store.dart';
import 'package:pay_by_second/application/settings.dart';
import 'package:pay_by_second/infrastructure/document_integrity.dart';
import 'package:pay_by_second/infrastructure/recoverable_settings_repository.dart';

class FaultStore extends MemoryKeyValueStore {
  String? failWrite;
  @override
  Future<void> write(String key, String value) async {
    if (key == failWrite) throw StateError('simulated storage failure');
    await super.write(key, value);
  }
}

void main() {
  final now = DateTime.utc(2026, 11, 10);
  Settings settings() => Settings(salary: '10000', start: DateTime.utc(2024));
  RecoverableSettingsRepository repo(KeyValueStore store) =>
      RecoverableSettingsRepository(store, now: () => now);
  test(
    'migration retains byte-identical v1 and original backup, idempotent across restarts',
    () async {
      final store = FaultStore(), raw = jsonEncode(settings().toJson());
      store.values[RecoverableSettingsRepository.legacyKey] = raw;
      final first = await repo(store).load();
      expect(first!.migrationPending, isFalse);
      expect(first.document!.salaries.length, 1);
      expect(store.values[RecoverableSettingsRepository.legacyKey], raw);
      expect(store.values[RecoverableSettingsRepository.originalKey], raw);
      final committed = store.values[RecoverableSettingsRepository.profileKey];
      final second = await repo(store).load();
      expect(second!.document!.revision, 1);
      expect(store.values[RecoverableSettingsRepository.profileKey], committed);
    },
  );
  test(
    'migration failure returns visible pending state with unchanged original, retry succeeds',
    () async {
      for (final key in [
        RecoverableSettingsRepository.originalKey,
        RecoverableSettingsRepository.profileKey,
      ]) {
        final store = FaultStore()..failWrite = key;
        final raw = jsonEncode(settings().toJson());
        store.values[RecoverableSettingsRepository.legacyKey] = raw;
        expect((await repo(store).load())!.migrationPending, isTrue);
        expect(store.values[RecoverableSettingsRepository.legacyKey], raw);
        store.failWrite = null;
        expect((await repo(store).load())!.migrationPending, isFalse);
      }
    },
  );
  test(
    'failed update retains prior primary and retry does not duplicate history',
    () async {
      final store = FaultStore(), repository = repo(store);
      await repository.save(settings());
      final loaded = (await repository.load())!;
      final old = store.values[RecoverableSettingsRepository.profileKey];
      store.failWrite = RecoverableSettingsRepository.profileKey;
      final edit = loaded.copyWith(
        salary: '20000',
        effectiveFrom: DateTime.utc(2026, 7),
      );
      await expectLater(repository.save(edit), throwsStateError);
      expect(store.values[RecoverableSettingsRepository.profileKey], old);
      store.failWrite = null;
      await repository.save(edit);
      expect((await repository.load())!.document!.salaries.length, 2);
    },
  );
  test(
    'corrupt v2 fails closed; explicit last-good recovery retains damaged bytes',
    () async {
      final store = FaultStore(), repository = repo(store);
      await repository.save(settings());
      final loaded = (await repository.load())!;
      await repository.save(
        loaded.copyWith(salary: '20000', effectiveFrom: DateTime.utc(2026, 7)),
      );
      store.values[RecoverableSettingsRepository.profileKey] = 'not-json';
      await expectLater(repository.load(), throwsFormatException);
      expect(
        store.values[RecoverableSettingsRepository.profileKey],
        'not-json',
      );
      await repository.restorePrevious();
      expect((await repository.load())!.salary, '10000');
      expect(
        store.values[RecoverableSettingsRepository.damagedKey],
        'not-json',
      );
    },
  );
  test(
    'downgraded application edits are detected, never silently overwritten',
    () async {
      final store = FaultStore(), repository = repo(store);
      store.values[RecoverableSettingsRepository.legacyKey] = jsonEncode(
        settings().toJson(),
      );
      final loaded = (await repository.load())!;
      final old = store.values[RecoverableSettingsRepository.profileKey];
      store.values[RecoverableSettingsRepository.legacyKey] = jsonEncode(
        settings().copyWith(salary: '9000').toJson(),
      );
      await expectLater(
        repository.load(),
        throwsA(isA<ProfileRecoveryException>()),
      );
      await expectLater(
        repository.save(loaded.copyWith(salary: '20000')),
        throwsA(isA<ProfileRecoveryException>()),
      );
      expect(store.values[RecoverableSettingsRepository.profileKey], old);
      await repository.restoreLegacy();
      expect((await repository.load())!.salary, '9000');
      expect(store.values[RecoverableSettingsRepository.damagedKey], old);
    },
  );
  test(
    'concurrent same-revision writes serialize and reject the stale one',
    () async {
      final store = FaultStore(), repository = repo(store);
      await repository.save(settings());
      final loaded = (await repository.load())!;
      final results = await Future.wait([
        repository
            .save(loaded.copyWith(salary: '20000'))
            .then<Object>((_) => 'ok', onError: (Object e) => e),
        repository
            .save(loaded.copyWith(salary: '30000'))
            .then<Object>((_) => 'ok', onError: (Object e) => e),
      ]);
      expect(results.where((v) => v == 'ok').length, 1);
      expect((await repository.load())!.salary, '20000');
    },
  );
  test('canonical integrity detects tampering and oversized imports', () {
    final sealed = sealedDocument({
      'b': 2,
      'a': {'z': 3, 'c': 4},
    });
    expect(openDocument(sealed)['payload'], {
      'a': {'c': 4, 'z': 3},
      'b': 2,
    });
    expect(
      () => openDocument(sealed.replaceFirst('"b":2', '"b":9')),
      throwsFormatException,
    );
    expect(
      () => openDocument('x' * (maxDocumentBytes + 1)),
      throwsFormatException,
    );
  });
}
