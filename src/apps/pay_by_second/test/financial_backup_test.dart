import 'package:flutter_test/flutter_test.dart';
import 'package:pay_by_second/application/key_value_store.dart';
import 'package:pay_by_second/application/settings.dart';
import 'package:pay_by_second/infrastructure/financial_backup.dart';
import 'package:pay_by_second/infrastructure/document_integrity.dart';
import 'package:pay_by_second/infrastructure/recoverable_settings_repository.dart';

class InterruptedStore extends MemoryKeyValueStore {
  bool interrupted = false;
  String? failKey;
  @override
  Future<void> write(String key, String value) async {
    if (interrupted || key == failKey) {
      interrupted = true;
      throw StateError('power loss');
    }
    await super.write(key, value);
  }
}

void main() {
  Future<MemoryKeyValueStore> source(String salary) async {
    final store = MemoryKeyValueStore();
    await RecoverableSettingsRepository(
      store,
    ).save(Settings(salary: salary, start: DateTime.utc(2024)));
    return store;
  }

  test('full financial backup roundtrip validates schema and digest', () async {
    final original = await source('12345.67'), target = await source('8000');
    final service = FinancialBackup(target),
        text = await FinancialBackup(original).export();
    final preview = await service.preview(text);
    expect(preview.salaryRules, 1);
    expect(preview.scheduleRules, 1);
    await service.apply(preview);
    expect(
      (await RecoverableSettingsRepository(target).load())!.salary,
      '12345.67',
    );
    expect(target.values.containsKey(FinancialBackup.journalKey), false);
    await expectLater(
      service.preview(text.replaceFirst('12345.67', '99999.99')),
      throwsFormatException,
    );
  });
  test('preview becomes stale when financial data changes', () async {
    final target = await source('8000'), original = await source('9000');
    final service = FinancialBackup(target),
        preview = await FinancialBackup(
          target,
        ).preview(await FinancialBackup(original).export());
    target.values['pay_by_second.overtime.v1'] = '{}';
    await expectLater(service.apply(preview), throwsStateError);
    expect(
      (await RecoverableSettingsRepository(target).load())!.salary,
      '8000',
    );
  });
  test(
    'interrupted multi-key import restores exact originals before readers resume',
    () async {
      final target = InterruptedStore()
        ..values.addAll((await source('8000')).values);
      final before = Map<String, String>.from(target.values),
          service = FinancialBackup(target);
      final preview = await service.preview(
        await FinancialBackup(await source('9000')).export(),
      );
      // Profile is replaced first. Simulate loss while writing retained legacy copy.
      target.failKey = RecoverableSettingsRepository.previousKey;
      // Ensure this key is present in the incoming backup so it calls write.
      final changedValues = {
        ...preview.values,
        RecoverableSettingsRepository.previousKey:
            before[RecoverableSettingsRepository.profileKey],
      };
      await expectLater(
        service.apply(
          BackupPreview(changedValues, preview.expectedDigest, 1, 1, 0),
        ),
        throwsStateError,
      );
      expect(target.values.containsKey(FinancialBackup.journalKey), true);
      target.interrupted = false;
      target.failKey = null;
      await service.recoverInterruptedImport();
      expect(
        {...target.values}..remove(FinancialBackup.previousImportKey),
        before,
      );
      expect(
        openDocument(
          target.values[FinancialBackup.previousImportKey]!,
        )['payload'],
        containsPair(
          RecoverableSettingsRepository.profileKey,
          before[RecoverableSettingsRepository.profileKey],
        ),
      );
    },
  );
  test('unknown backup keys and corrupt journal fail closed', () async {
    final store = await source('8000'), service = FinancialBackup(store);
    final raw =
        openDocument(await service.export())['payload'] as Map<String, dynamic>;
    (raw['values'] as Map)['unrelated.system.key'] = 'bad';
    await expectLater(
      service.preview(sealedDocument(raw)),
      throwsFormatException,
    );
    final before = Map.of(store.values);
    store.values[FinancialBackup.journalKey] = 'corrupt';
    await expectLater(
      service.recoverInterruptedImport(),
      throwsFormatException,
    );
    expect(
      store.values[RecoverableSettingsRepository.profileKey],
      before[RecoverableSettingsRepository.profileKey],
    );
  });
}
