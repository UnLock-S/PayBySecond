import 'package:earnings_core/earnings_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_by_second/application/settings.dart';

void main() {
  test(
    'AUD-07 rejects a persisted employment date that normalizes to another date',
    () {
      final json = Settings(salary: '10000', start: DateTime.utc(2026)).toJson()
        ..['start'] = '2026-02-30';
      expect(() => Settings.fromJson(json), throwsFormatException);
    },
  );
  test(
    'AUD-07 every constructible overtime interval can be persisted and restored',
    () {
      final policy = OvertimePolicy(monthlyMinor: BigInt.from(1000000));
      expect(
        () => OvertimeEntry(id: 1, start: DateTime.utc(1969), policy: policy),
        throwsArgumentError,
      );
      expect(
        () => OvertimeEntry(
          id: 1,
          start: DateTime.utc(2026),
          end: DateTime.utc(2101),
          policy: policy,
        ),
        throwsArgumentError,
      );
    },
  );
  test('AUD-06 rejects calculations beyond the documented end of 2100', () {
    final engine = EarningsEngine(
      EarningsPolicy(
        monthlyMinor: BigInt.from(1000000),
        startDate: DateTime.utc(2026),
      ),
    );
    expect(
      () => engine.betweenCivil(DateTime.utc(2100), DateTime.utc(2101, 2)),
      throwsArgumentError,
    );
  });
  test(
    'AUD-01 legacy overnight semantics are calendar-date based, not shift-anchor based',
    () {
      final settings = Settings(
        salary: '10000',
        start: DateTime.utc(2026),
        mode: AccrualMode.work,
        weekdays: {5},
        startMinute: 1320,
        endMinute: 360,
        lunch: false,
      );
      final engine = EarningsEngine(settings.toPolicy());
      expect(
        engine.ratePerSecond(DateTime.utc(2026, 11, 6, 15)).numerator,
        greaterThan(BigInt.zero),
      );
      expect(
        engine.ratePerSecond(DateTime.utc(2026, 11, 6, 17)).numerator,
        BigInt.zero,
      );
    },
  );
  test(
    'AUD-06 signed money display rounds half away from zero without negative zero',
    () {
      expect(Money(BigInt.from(-1005), BigInt.from(1000)).format(2), '-1.01');
      expect(Money(BigInt.from(-1), BigInt.from(1000000)).format(2), '0.00');
      expect(Money(BigInt.zero, BigInt.from(7)).format(6), '0.000000');
    },
  );
}
