import 'package:earnings_core/earnings_core.dart';
import 'package:test/test.dart';

void main() {
  EarningsPolicy policy({
    AccrualMode mode = AccrualMode.calendar,
    SalaryBasis basis = SalaryBasis.annual,
    DateTime? start,
    Set<int> weekdays = const {1, 2, 3, 4, 5},
    Map<String, bool> overrides = const {},
  }) => EarningsPolicy(
    monthlyMinor: BigInt.from(1000000),
    startDate: start ?? DateTime.utc(2024),
    mode: mode,
    basis: basis,
    weekdays: weekdays,
    dateOverrides: overrides,
  );
  test('complete leap and non-leap years preserve annual salary', () {
    final engine = EarningsEngine(policy());
    for (final year in [2024, 2025]) {
      expect(
        engine
            .betweenCivil(DateTime.utc(year), DateTime.utc(year + 1))
            .format(2),
        '120000.00',
      );
    }
  });
  test('annual and monthly bases deliberately differ in January', () {
    expect(
      EarningsEngine(
        policy(),
      ).betweenCivil(DateTime.utc(2025), DateTime.utc(2025, 2)).format(2),
      '10191.78',
    );
    expect(
      EarningsEngine(
        policy(basis: SalaryBasis.monthly),
      ).betweenCivil(DateTime.utc(2025), DateTime.utc(2025, 2)).format(2),
      '10000.00',
    );
  });
  test('entry clips numerator, future employment earns zero', () {
    final engine = EarningsEngine(policy(start: DateTime.utc(2025, 7, 1)));
    expect(
      engine.earned(Period.employment, DateTime.utc(2025, 6, 1)),
      Money.zero,
    );
    expect(
      engine.betweenCivil(DateTime.utc(2025), DateTime.utc(2026)).format(2),
      '60493.15',
    );
  });
  test('lunch break and end boundary stop accrual', () {
    final engine = EarningsEngine(policy(mode: AccrualMode.work));
    // Monday local 12:00 and 13:00 are UTC 04:00 and 05:00.
    final noon = DateTime.utc(2025, 1, 6, 4);
    expect(
      engine.earned(Period.day, noon).format(6),
      engine.earned(Period.day, noon.add(const Duration(hours: 1))).format(6),
    );
    expect(engine.ratePerSecond(noon).format(6), '0.000000');
    expect(
      engine.ratePerSecond(DateTime.utc(2025, 1, 6, 9)).format(6),
      '0.000000',
    );
    expect(
      engine.betweenCivil(DateTime.utc(2025), DateTime.utc(2026)).format(2),
      '120000.00',
    );
  });
  test('date overrides implement Sunday makeup and weekday leave', () {
    final engine = EarningsEngine(
      policy(
        mode: AccrualMode.work,
        overrides: {'2025-01-05': true, '2025-01-06': false},
      ),
    );
    expect(
      engine.ratePerSecond(DateTime.utc(2025, 1, 5, 2)).numerator > BigInt.zero,
      isTrue,
    );
    expect(engine.ratePerSecond(DateTime.utc(2025, 1, 6, 2)).format(2), '0.00');
  });
  test('zero working denominator returns zero', () {
    final engine = EarningsEngine(policy(mode: AccrualMode.work, weekdays: {}));
    expect(
      engine.betweenCivil(DateTime.utc(2025), DateTime.utc(2026)).format(2),
      '0.00',
    );
  });
  test('overlapping spans merge and overnight is split', () {
    final engine = EarningsEngine(
      EarningsPolicy(
        monthlyMinor: BigInt.from(1000000),
        startDate: DateTime.utc(2025),
        mode: AccrualMode.work,
        weekdays: {1, 2, 3, 4, 5, 6, 7},
        spans: const [
          WorkSpan(0, 360),
          WorkSpan(1320, 1440),
          WorkSpan(60, 120),
        ],
      ),
    );
    expect(
      engine
          .betweenCivil(
            DateTime.utc(2025, 1, 1, 22),
            DateTime.utc(2025, 1, 2, 6),
          )
          .format(6),
      '328.767123',
    );
  });
  test('rounding is exact, carries and large money survive', () {
    expect(Money(BigInt.from(199999), BigInt.from(100000)).format(4), '2.0000');
    expect(
      Money(BigInt.parse('900719925474099312345'), BigInt.from(100)).format(2),
      '9007199254740993123.45',
    );
  });
  test('partition invariance and no tick accumulation', () {
    final engine = EarningsEngine(policy());
    final start = DateTime.utc(2025, 1, 1, 8);
    var parts = Money.zero;
    for (var i = 0; i < 100; i++) {
      parts += engine.betweenCivil(
        start.add(Duration(milliseconds: i * 100)),
        start.add(Duration(milliseconds: (i + 1) * 100)),
      );
    }
    final direct = engine.betweenCivil(
      start,
      start.add(const Duration(seconds: 10)),
    );
    expect(parts.format(6), direct.format(6));
  });
}
