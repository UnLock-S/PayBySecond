import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:earnings_core/earnings_core.dart';
import 'package:pay_by_second/application/key_value_store.dart';
import 'package:pay_by_second/infrastructure/policy_repository.dart';
import 'package:pay_by_second/infrastructure/document_integrity.dart';

void main() {
  final fixture = File('assets/policy/cn-2026.json').readAsStringSync();
  test(
    'bundled candidate digest matches; leave arrangements never manufacture statutory classification',
    () {
      final data = PolicyRepository(MemoryKeyValueStore()).decode(fixture);
      expect(data.source.review, PolicyReview.pending);
      expect(
        data.on(DateTime.utc(2026, 2, 15)).classification,
        HolidayClassification.unknown,
      );
      expect(data.workOverrides['2026-02-15'], false);
      expect(data.workOverrides['2026-02-14'], true);
      expect(
        data.on(DateTime.utc(2027)).classification,
        HolidayClassification.unknown,
      );
      expect(
        File('../../../config/policy/cn-2026.json').readAsStringSync(),
        fixture,
      );
    },
  );
  test(
    'updates require explicit call, offline failure keeps cache; same-version mutation rejected',
    () async {
      final store = MemoryKeyValueStore();
      var calls = 0;
      final repository = PolicyRepository(
        store,
        fetch: (_) async {
          calls++;
          throw StateError('offline');
        },
      );
      expect(calls, 0);
      await repository.cache(fixture);
      await expectLater(repository.update(), throwsStateError);
      expect(calls, 1);
      expect(
        (await repository.load())!.version,
        'cn-2026.arrangements.pending.1',
      );
      final changed = openDocument(fixture)['payload'] as Map<String, dynamic>;
      (changed['days'] as Map)['2026-01-01'] = {
        'classification': 'statutoryHoliday',
        'working': false,
      };
      await expectLater(
        repository.cache(sealedDocument(changed)),
        throwsStateError,
      );
      expect(store.values[PolicyRepository.key], fixture);
    },
  );
  test(
    'versioned cache rollback retains both versions; provenance and checksum failures reject writes',
    () async {
      final store = MemoryKeyValueStore(),
          repository = PolicyRepository(MemoryKeyValueStore());
      final repo = PolicyRepository(store);
      await repo.cache(fixture);
      final changed = openDocument(fixture)['payload'] as Map<String, dynamic>;
      changed['version'] = 'cn-2026.arrangements.pending.2';
      changed['revision'] = 2;
      final next = sealedDocument(changed);
      await repo.cache(next);
      await repo.rollback();
      expect(store.values[PolicyRepository.key], fixture);
      expect(store.values[PolicyRepository.previousKey], next);
      await expectLater(
        repo.cache(next.replaceFirst('CN-mainland', 'JP')),
        throwsFormatException,
      );
      (changed['source'] as Map)['review'] = 'humanReviewed';
      expect(
        () => repository.decode(sealedDocument(changed)),
        throwsArgumentError,
      );
    },
  );
}
