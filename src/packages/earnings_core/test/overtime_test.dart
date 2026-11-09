import 'package:earnings_core/earnings_core.dart';
import 'package:test/test.dart';

void main() {
  test(
    'standard hourly base and all statutory rates, including compensatory leave',
    () {
      // 17400 / 174 = 100 yuan per hour.
      for (final day in OvertimeDay.values) {
        final policy = OvertimePolicy(
          monthlyMinor: BigInt.from(1740000),
          pay: OvertimePay.statutory,
          day: day,
        );
        final expected = {
          OvertimeDay.weekday: '150.00',
          OvertimeDay.rest: '200.00',
          OvertimeDay.holiday: '300.00',
        }[day];
        expect(policy.expected(const Duration(hours: 1)).format(2), expected);
      }
      final leave = OvertimePolicy(
        monthlyMinor: BigInt.from(1740000),
        pay: OvertimePay.statutory,
        day: OvertimeDay.rest,
        compensatoryLeave: true,
      );
      expect(leave.statutory(const Duration(hours: 1)).format(2), '0.00');
      final holiday = OvertimePolicy(
        monthlyMinor: BigInt.from(1740000),
        pay: OvertimePay.statutory,
        day: OvertimeDay.holiday,
        compensatoryLeave: true,
      );
      expect(holiday.expected(const Duration(hours: 1)).format(2), '300.00');
    },
  );
  test(
    'unpaid joke is one-times time value, separate from statutory cash reference',
    () {
      final p = OvertimePolicy(
        monthlyMinor: BigInt.from(1740000),
        day: OvertimeDay.holiday,
      );
      const duration = Duration(hours: 2);
      expect(p.expected(duration).format(2), '0.00');
      expect(p.unpaidValue(duration).format(2), '200.00');
      expect(p.statutory(duration).format(2), '600.00');
    },
  );
  test(
    'custom and single multipliers are exact even at subsecond resolution',
    () {
      final p = OvertimePolicy(
        monthlyMinor: BigInt.from(1740000),
        pay: OvertimePay.custom,
        multiplier: 235,
      );
      expect(p.expected(const Duration(hours: 1)).format(2), '235.00');
      final slice = p.expected(const Duration(milliseconds: 100));
      expect(slice.scale(36000).format(6), '235.000000');
      final single = OvertimePolicy(
        monthlyMinor: BigInt.from(1740000),
        pay: OvertimePay.single,
      );
      expect(single.expected(const Duration(hours: 1)).format(2), '100.00');
      expect(
        () => OvertimePolicy(monthlyMinor: BigInt.one, multiplier: 0),
        throwsArgumentError,
      );
    },
  );
  test('cross-midnight elapsed, snapshot serialization and clock rollback', () {
    final start = DateTime.utc(2026, 11, 9, 15, 30);
    final p = OvertimePolicy(monthlyMinor: BigInt.from(1740000));
    final e = OvertimeEntry(id: 1, start: start, policy: p);
    final end = start.add(const Duration(hours: 3));
    expect(
      OvertimeEntry.fromJson(e.stop(end).toJson()).elapsed(end),
      const Duration(hours: 3),
    );
    expect(
      e.elapsed(start.subtract(const Duration(seconds: 1))),
      Duration.zero,
    );
    expect(
      () => e.stop(start.subtract(const Duration(seconds: 1))),
      throwsArgumentError,
    );
  });
}
