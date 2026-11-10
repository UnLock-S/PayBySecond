import 'package:earnings_core/earnings_core.dart';
import 'package:test/test.dart';

void main() {
  OvertimePolicy policy({
    bool scope = true,
    bool arranged = true,
    bool reviewed = true,
    OvertimeDay day = OvertimeDay.weekday,
    bool leave = false,
  }) => OvertimePolicy(
    monthlyMinor: BigInt.from(1740000),
    pay: OvertimePay.statutory,
    day: day,
    compensatoryLeave: leave,
    referenceVersion: cnStandard2025['id']!,
    standardHoursConfirmed: scope,
    employerArranged: arranged,
    sourceReviewedAt: reviewed ? DateTime.utc(2026, 11, 10) : null,
    classificationDate: '2026-11-10',
  );
  test(
    'cross-midnight reference never guesses the following day classification',
    () {
      final entry = OvertimeEntry(
        id: 1,
        start: DateTime.utc(2026, 11, 10, 15),
        end: DateTime.utc(2026, 11, 10, 17),
        policy: policy(),
      );
      final result = entry.reference(entry.end!);
      expect(result.knownCash.format(2), '150.00');
      expect(result.pendingDuration, const Duration(hours: 1));
      expect(entry.expectedAt(entry.end!).format(2), '150.00');
    },
  );
  test(
    'unconfirmed conditions give pending time instead of a false cash zero entitlement',
    () {
      for (final p in [
        policy(scope: false),
        policy(arranged: false),
        policy(reviewed: false),
      ]) {
        final entry = OvertimeEntry(
          id: 1,
          start: DateTime.utc(2026, 11, 10),
          end: DateTime.utc(2026, 11, 10, 1),
          policy: p,
        );
        expect(
          entry.reference(entry.end!).pendingDuration,
          const Duration(hours: 1),
        );
        expect(entry.reference(entry.end!).knownCash.format(2), '0.00');
      }
    },
  );
  test(
    'rest-day leave separates recorded hours from cash; statutory holiday cannot be waived by leave',
    () {
      for (final day in [OvertimeDay.rest, OvertimeDay.holiday]) {
        final entry = OvertimeEntry(
          id: 1,
          start: DateTime.utc(2026, 11, 10),
          end: DateTime.utc(2026, 11, 10, 2),
          policy: policy(day: day, leave: true),
        );
        final result = entry.reference(entry.end!);
        expect(
          result.knownCash.format(2),
          day == OvertimeDay.rest ? '0.00' : '600.00',
        );
        expect(
          result.compensatoryDuration,
          day == OvertimeDay.rest ? const Duration(hours: 2) : Duration.zero,
        );
      }
    },
  );
  test(
    'corrections retain prior end and timestamp, serialization preserves immutable assumptions',
    () {
      final old = OvertimeEntry(
        id: 1,
        start: DateTime.utc(2026, 11, 10),
        end: DateTime.utc(2026, 11, 10, 1),
        policy: policy(),
      );
      final revised = old.correctEnd(
        DateTime.utc(2026, 11, 10, 2),
        DateTime.utc(2026, 11, 11),
      );
      final read = OvertimeEntry.fromJson(revised.toJson());
      expect(read.previousEnds, [old.end!.toIso8601String()]);
      expect(read.correctedAt, DateTime.utc(2026, 11, 11));
      expect(read.expectedAt(read.end!).format(2), '300.00');
      expect(old.end, DateTime.utc(2026, 11, 10, 1));
    },
  );
  test(
    'legacy snapshot preserves original cross-day arithmetic and is marked unverified',
    () {
      final old = OvertimePolicy(
        monthlyMinor: BigInt.from(1740000),
        pay: OvertimePay.statutory,
        day: OvertimeDay.holiday,
      );
      final entry = OvertimeEntry(
        id: 1,
        start: DateTime.utc(2024),
        end: DateTime.utc(2024, 1, 2),
        policy: old,
      );
      expect(entry.policy.legacy, true);
      expect(entry.reference(entry.end!).knownCash.format(2), '7200.00');
      expect(entry.reference(entry.end!).pendingDuration, Duration.zero);
    },
  );
}
