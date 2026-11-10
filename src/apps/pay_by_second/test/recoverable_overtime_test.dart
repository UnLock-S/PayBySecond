import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:earnings_core/earnings_core.dart';
import 'package:pay_by_second/application/key_value_store.dart';
import 'package:pay_by_second/application/overtime.dart';
import 'package:pay_by_second/infrastructure/recoverable_overtime_repository.dart';

class FailingStore extends MemoryKeyValueStore {
  bool fail = false;
  @override
  Future<void> write(String key, String value) async {
    if (fail && key == RecoverableOvertimeRepository.key) {
      throw StateError('storage full');
    }
    await super.write(key, value);
  }
}

void main() {
  final policy = OvertimePolicy(
    monthlyMinor: BigInt.from(1740000),
    pay: OvertimePay.statutory,
    day: OvertimeDay.holiday,
  );
  final legacy =
      OvertimeBook(
          policy: policy,
        ).start(DateTime.utc(2026)).stop(DateTime.utc(2026, 1, 1, 1)).toJson()
        ..['version'] = 1;
  test(
    'legacy ledger migration retains original and exact historical calculation, restart is idempotent',
    () async {
      final store = FailingStore(), raw = jsonEncode(legacy);
      store.values[RecoverableOvertimeRepository.legacyKey] = raw;
      final repo = RecoverableOvertimeRepository(store),
          book = await repo.load();
      expect(
        book.entries.single
            .reference(book.entries.single.end!)
            .knownCash
            .format(2),
        '300.00',
      );
      expect(store.values[RecoverableOvertimeRepository.legacyKey], raw);
      final migrated = store.values[RecoverableOvertimeRepository.key];
      await RecoverableOvertimeRepository(store).load();
      expect(store.values[RecoverableOvertimeRepository.key], migrated);
    },
  );
  test(
    'migration and save failures never clear legacy or last committed ledger',
    () async {
      final store = FailingStore()
        ..values[RecoverableOvertimeRepository.legacyKey] = jsonEncode(legacy)
        ..fail = true;
      final repo = RecoverableOvertimeRepository(store);
      await expectLater(repo.load(), throwsStateError);
      expect(
        store.values[RecoverableOvertimeRepository.legacyKey],
        jsonEncode(legacy),
      );
      store.fail = false;
      final book = await repo.load(),
          raw = store.values[RecoverableOvertimeRepository.key];
      store.fail = true;
      await expectLater(
        repo.save(book.start(DateTime.utc(2026, 1, 2))),
        throwsStateError,
      );
      expect(store.values[RecoverableOvertimeRepository.key], raw);
      store.fail = false;
      await repo.save(book.start(DateTime.utc(2026, 1, 2)));
      expect((await repo.load()).active, isNotNull);
    },
  );
  test('stale writers and legacy changes are rejected', () async {
    final store = FailingStore()
      ..values[RecoverableOvertimeRepository.legacyKey] = jsonEncode(legacy);
    final a = RecoverableOvertimeRepository(store),
        b = RecoverableOvertimeRepository(store);
    final old = await a.load();
    await b.load();
    await a.save(old.start(DateTime.utc(2026, 1, 2)));
    await expectLater(b.save(old), throwsStateError);
    store.values[RecoverableOvertimeRepository.legacyKey] = '{}';
    await expectLater(a.load(), throwsStateError);
  });
}
