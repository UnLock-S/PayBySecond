import 'dart:convert';
import 'dart:io';
import 'package:earnings_core/earnings_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_by_second/application/settings.dart';
import 'package:pay_by_second/infrastructure/document_integrity.dart';

void main() {
  final now = DateTime.utc(2026, 11, 10);
  ProfileDocument profile() => ProfileDocument.initial(
    Settings(salary: '10000', start: DateTime.utc(2024)),
    now,
  );
  test(
    'calendar source snapshot survives history edits and flows into every relevant exact trace',
    () {
      final data = CalendarDataset.fromJson(
        openDocument(
              File('assets/policy/cn-2026.json').readAsStringSync(),
            )['payload']
            as Map<String, dynamic>,
      );
      final digest = textDigest(canonicalJson(data.toJson()));
      final initial = profile();
      final next = initial.change(
        initial
            .view(now)
            .copyWith(
              policyOverrides: data.workOverrides,
              calendarVersion: data.version,
              calendarSource: {
                'version': data.version,
                'source': data.source.toJson(),
                'datasetSha256': digest,
                'personalReviewedAt': now.toIso8601String(),
              },
              effectiveFrom: DateTime.utc(2026),
            ),
        now,
      );
      final restored = ProfileDocument.fromJson(
        jsonDecode(jsonEncode(next.toJson())) as Map<String, dynamic>,
      );
      expect(restored.view(now).calendarSource['datasetSha256'], digest);
      final trace = restored
          .engine()
          .traceBetweenCivil(DateTime.utc(2026, 1), DateTime.utc(2026, 2))
          .single;
      expect(trace.toJson()['calendarVersion'], data.version);
      expect(trace.toJson()['calendarSourceDigest'], digest);
      final payChange = restored.change(
        restored.view(now).copyWith(salary: '20000'),
        now,
      );
      expect(payChange.view(now).calendarSource['datasetSha256'], digest);
      expect(
        () => (payChange.view(now).calendarSource['source'] as Map)['region'] =
            'JP',
        throwsUnsupportedError,
      );
    },
  );
  test(
    'explicit dated copy can apply the current salary to an earlier interval without changing the schedule',
    () {
      final initial = profile();
      final current = initial.change(
        initial
            .view(now)
            .copyWith(salary: '20000', effectiveFrom: DateTime.utc(2026, 7)),
        now,
      );
      final revised = current.change(
        current
            .view(now)
            .copyWith(
              effectiveFrom: DateTime.utc(2026, 3),
              salaryVersionRequested: true,
            ),
        now,
      );
      expect(revised.salaryAt(DateTime.utc(2026, 4)).salary, '20000');
      expect(
        revised.scheduleAt(DateTime.utc(2026, 4)).id,
        initial.schedules.single.id,
      );
      expect(revised.salaries.length, 3);
      expect(
        () => revised.change(
          revised
              .view(now)
              .copyWith(effectiveFrom: DateTime.utc(2026, 1, 1, 1)),
          now,
        ),
        throwsFormatException,
      );
    },
  );
  test(
    'v1 baseline converts without inventing history or changing any income',
    () {
      final original = Settings(
        salary: '12345.67',
        start: DateTime.utc(2024),
        mode: AccrualMode.work,
        startMinute: 1320,
        endMinute: 360,
        lunch: false,
      );
      final migrated = ProfileDocument.initial(original, now);
      final restored = ProfileDocument.fromJson(
        jsonDecode(jsonEncode(migrated.toJson())) as Map<String, dynamic>,
      );
      expect(restored.salaries.length, 1);
      expect(restored.schedules.length, 1);
      expect(
        restored.view(now).shiftAttribution,
        ShiftAttribution.calendarDate,
      );
      for (final date in [DateTime.utc(2024, 3), DateTime.utc(2025), now]) {
        expect(
          restored.engine().earned(Period.employment, date).format(6),
          EarningsEngine(
            original.toPolicy(),
          ).earned(Period.employment, date).format(6),
        );
      }
    },
  );
  test(
    'salary and schedule changes are independent and preserve previous intervals',
    () {
      final before = profile();
      final salary = before.change(
        before
            .view(now)
            .copyWith(salary: '20000', effectiveFrom: DateTime.utc(2026, 7)),
        now,
      );
      expect(salary.salaries.length, 2);
      expect(salary.schedules.length, 1);
      final work = salary.change(
        salary
            .view(now)
            .copyWith(
              mode: AccrualMode.work,
              effectiveFrom: DateTime.utc(2026, 10),
            ),
        now,
      );
      expect(work.salaries.length, 2);
      expect(work.schedules.length, 2);
      expect(
        work
            .engine()
            .betweenCivil(DateTime.utc(2026), DateTime.utc(2026, 7))
            .format(6),
        before
            .engine()
            .betweenCivil(DateTime.utc(2026), DateTime.utc(2026, 7))
            .format(6),
      );
    },
  );
  test('future rules activate by query time, not at configuration save', () {
    final before = profile();
    final future = before.change(
      before
          .view(now)
          .copyWith(salary: '20000', effectiveFrom: DateTime.utc(2027)),
      now,
    );
    expect(future.view(now).salary, '10000');
    expect(future.view(DateTime.utc(2027)).salary, '20000');
    expect(
      future
          .engine()
          .ratePerSecond(DateTime.utc(2027))
          .scale(365 * 86400)
          .format(2),
      '240000.00',
    );
  });
  test(
    'same-date corrections archive the exact replaced value and reject stale drafts',
    () {
      final first = profile();
      final changed = first.change(
        first
            .view(now)
            .copyWith(
              salary: '20000',
              effectiveFrom: DateTime.utc(2026, 11, 10),
            ),
        now,
      );
      final corrected = changed.change(
        changed
            .view(now)
            .copyWith(
              salary: '21000',
              effectiveFrom: DateTime.utc(2026, 11, 10),
            ),
        now,
      );
      expect(corrected.salaries.length, 2);
      expect(corrected.replaced.length, 1);
      expect((corrected.replaced.single['previous'] as Map)['salary'], '20000');
      expect(
        () => corrected.change(first.view(now).copyWith(salary: '30000'), now),
        throwsFormatException,
      );
    },
  );
  test(
    'effective default follows UTC+08 civil midnight; nested snapshots are immutable',
    () {
      final first = profile();
      final changed = first.change(
        first.view(now).copyWith(salary: '20000'),
        DateTime.utc(2026, 11, 9, 17),
      );
      expect(changed.salaries.last.from, DateTime.utc(2026, 11, 10));
      expect(
        () => (changed.schedules.first.fields['weekdays'] as List).add(7),
        throwsUnsupportedError,
      );
    },
  );
  test(
    'custom intervals and breaks compile both calendar-date and anchored schedules',
    () {
      final settings = Settings(
        salary: '10000',
        start: DateTime.utc(2024),
        mode: AccrualMode.work,
        weekdays: {5},
        startMinute: 1320,
        endMinute: 360,
        lunch: false,
        intervals: [WorkInterval(1320, 360)],
        breaks: [WorkInterval(0, 60)],
        shiftAttribution: ShiftAttribution.shiftStartDate,
      );
      final engine = EarningsEngine(settings.toPolicy());
      expect(
        engine.ratePerSecond(DateTime.utc(2026, 11, 6, 16, 30)).numerator,
        BigInt.zero,
      );
      expect(
        engine.ratePerSecond(DateTime.utc(2026, 11, 6, 17, 30)).numerator,
        greaterThan(BigInt.zero),
      );
      expect(
        Settings.fromJson(settings.toJson()).toPolicy().anchoredSpans.length,
        2,
      );
      expect(() => WorkInterval(1, 1), throwsFormatException);
    },
  );
}
