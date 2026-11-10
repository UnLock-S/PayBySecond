import 'package:earnings_core/earnings_core.dart';
import 'package:test/test.dart';

EarningsPolicy base({
  AccrualMode mode = AccrualMode.calendar,
  SalaryBasis basis = SalaryBasis.annual,
  ShiftAttribution attribution = ShiftAttribution.calendarDate,
  Set<int> weekdays = const {1, 2, 3, 4, 5},
  Map<String, bool> overrides = const {},
}) => EarningsPolicy(
  monthlyMinor: BigInt.from(1000000),
  startDate: DateTime.utc(2020),
  mode: mode,
  basis: basis,
  weekdays: weekdays,
  spans: const [WorkSpan(0, 360), WorkSpan(1320, 1440)],
  anchoredSpans: [AnchoredWorkSpan(1320, 1800)],
  shiftAttribution: attribution,
  dateOverrides: overrides,
);

void main() {
  test(
    'shift-anchor Friday continues into Saturday; calendar-date legacy remains unchanged',
    () {
      final anchored = EarningsEngine(
        base(
          mode: AccrualMode.work,
          attribution: ShiftAttribution.shiftStartDate,
          weekdays: {5},
        ),
      );
      final legacy = EarningsEngine(
        base(mode: AccrualMode.work, weekdays: {5}),
      );
      final saturday = DateTime.utc(2026, 11, 6, 17);
      expect(
        anchored.ratePerSecond(saturday).numerator,
        greaterThan(BigInt.zero),
      );
      expect(legacy.ratePerSecond(saturday).numerator, BigInt.zero);
      expect(
        anchored
            .betweenCivil(
              DateTime.utc(2026, 11, 6, 22),
              DateTime.utc(2026, 11, 7, 6),
            )
            .format(6),
        '2307.692308',
      );
      expect(
        legacy
            .betweenCivil(
              DateTime.utc(2026, 11, 6, 22),
              DateTime.utc(2026, 11, 7, 6),
            )
            .scale(4)
            .format(6),
        '2307.692308',
      );
    },
  );
  test(
    'anchor overrides, Sunday/Monday and cross-year carry use the anchor date',
    () {
      final holiday = EarningsEngine(
        base(
          mode: AccrualMode.work,
          attribution: ShiftAttribution.shiftStartDate,
          weekdays: {5},
          overrides: {'2026-11-06': false},
        ),
      );
      expect(
        holiday.ratePerSecond(DateTime.utc(2026, 11, 6, 17)).numerator,
        BigInt.zero,
      );
      final sunday = EarningsEngine(
        base(
          mode: AccrualMode.work,
          attribution: ShiftAttribution.shiftStartDate,
          weekdays: {7},
        ),
      );
      expect(
        sunday.ratePerSecond(DateTime.utc(2026, 11, 8, 17)).numerator,
        greaterThan(BigInt.zero),
      );
      final yearEnd = EarningsEngine(
        base(
          mode: AccrualMode.work,
          attribution: ShiftAttribution.shiftStartDate,
          weekdays: {4},
        ),
      );
      expect(
        yearEnd.ratePerSecond(DateTime.utc(2026, 12, 31, 17)).numerator,
        greaterThan(BigInt.zero),
      );
    },
  );
  test(
    'split paid intervals keep an overnight break unpaid without double counting',
    () {
      final policy = EarningsPolicy(
        monthlyMinor: BigInt.from(1000000),
        startDate: DateTime.utc(2020),
        mode: AccrualMode.work,
        weekdays: {5},
        shiftAttribution: ShiftAttribution.shiftStartDate,
        anchoredSpans: [
          AnchoredWorkSpan(1320, 1440),
          AnchoredWorkSpan(1500, 1800),
          AnchoredWorkSpan(1510, 1520),
        ],
      );
      final engine = EarningsEngine(policy);
      expect(
        engine.ratePerSecond(DateTime.utc(2026, 11, 6, 16, 30)).numerator,
        BigInt.zero,
      );
      expect(
        engine.ratePerSecond(DateTime.utc(2026, 11, 6, 17, 30)).numerator,
        greaterThan(BigInt.zero),
      );
    },
  );
  VersionedEarningsEngine history({
    SalaryBasis basis = SalaryBasis.annual,
    DateTime? change,
  }) => VersionedEarningsEngine(
    initial: base(basis: basis),
    salaries: [
      SalaryRuleVersion(
        id: 'salary-1',
        effectiveFrom: DateTime.utc(2020),
        monthlyMinor: BigInt.from(1000000),
        basis: basis,
      ),
      SalaryRuleVersion(
        id: 'salary-2',
        effectiveFrom: change ?? DateTime.utc(2026, 7),
        monthlyMinor: BigInt.from(2000000),
        basis: basis,
      ),
    ],
    schedules: [
      ScheduleRuleVersion(
        id: 'schedule-1',
        effectiveFrom: DateTime.utc(2020),
        template: base(),
      ),
    ],
  );
  test(
    'annual salary versions use full-year denominators, not remaining employment time',
    () {
      final engine = history();
      expect(
        engine.betweenCivil(DateTime.utc(2026), DateTime.utc(2027)).format(6),
        Money(
          BigInt.from(120000 * 181 + 240000 * 184),
          BigInt.from(365),
        ).format(6),
      );
      expect(
        engine
            .betweenCivil(DateTime.utc(2026), DateTime.utc(2026, 7))
            .format(6),
        EarningsEngine(
          base(),
        ).betweenCivil(DateTime.utc(2026), DateTime.utc(2026, 7)).format(6),
      );
      expect(
        engine
            .ratePerSecond(DateTime.utc(2026, 7, 1))
            .scale(365 * 86400)
            .format(2),
        '240000.00',
      );
    },
  );
  test(
    'monthly midmonth change splits exact amounts and gives explainable rule IDs',
    () {
      final engine = history(
        basis: SalaryBasis.monthly,
        change: DateTime.utc(2026, 7, 16),
      );
      final start = DateTime.utc(2026, 7), end = DateTime.utc(2026, 8);
      final trace = engine.traceBetweenCivil(start, end);
      expect(trace.map((p) => p.salaryRuleId), ['salary-1', 'salary-2']);
      expect(trace.every((p) => p.denominatorMs == 31 * 86400000), isTrue);
      expect(
        trace.fold(Money.zero, (v, p) => v + p.amount).format(6),
        engine.betweenCivil(start, end).format(6),
      );
      expect(
        engine.betweenCivil(start, end).format(6),
        Money(BigInt.from(10000 * 15 + 20000 * 16), BigInt.from(31)).format(6),
      );
      expect(trace.first.toJson()['amountType'], 'simulated_accrual');
    },
  );
  test(
    'schedule versions preserve old intervals; invalid duplicate histories rejected',
    () {
      final first = base(mode: AccrualMode.work);
      final engine = VersionedEarningsEngine(
        initial: first,
        salaries: [
          SalaryRuleVersion(
            id: 's',
            effectiveFrom: DateTime.utc(2020),
            monthlyMinor: BigInt.from(1000000),
          ),
        ],
        schedules: [
          ScheduleRuleVersion(
            id: 'old',
            effectiveFrom: DateTime.utc(2020),
            template: first,
          ),
          ScheduleRuleVersion(
            id: 'new',
            effectiveFrom: DateTime.utc(2026, 7),
            template: base(
              mode: AccrualMode.work,
              weekdays: {1, 2, 3, 4, 5, 6, 7},
            ),
          ),
        ],
      );
      expect(
        engine
            .betweenCivil(DateTime.utc(2026), DateTime.utc(2026, 6))
            .format(6),
        EarningsEngine(
          first,
        ).betweenCivil(DateTime.utc(2026), DateTime.utc(2026, 6)).format(6),
      );
      expect(
        () => VersionedEarningsEngine(
          initial: first,
          salaries: [],
          schedules: engine.schedules,
        ),
        throwsArgumentError,
      );
      expect(
        () => VersionedEarningsEngine(
          initial: first,
          salaries: [engine.salaries.first, engine.salaries.first],
          schedules: engine.schedules,
        ),
        throwsArgumentError,
      );
    },
  );
  test(
    'versioned queries remain partition invariant across month and version boundaries',
    () {
      final engine = history(
        basis: SalaryBasis.monthly,
        change: DateTime.utc(2026, 7, 16),
      );
      final start = DateTime.utc(2026, 6, 30, 23, 59, 59),
          end = DateTime.utc(2026, 7, 17);
      final direct = engine.betweenCivil(start, end);
      final pieces =
          engine.betweenCivil(start, DateTime.utc(2026, 7)) +
          engine.betweenCivil(
            DateTime.utc(2026, 7),
            DateTime.utc(2026, 7, 16),
          ) +
          engine.betweenCivil(DateTime.utc(2026, 7, 16), end);
      expect(
        pieces.numerator * direct.denominator,
        direct.numerator * pieces.denominator,
      );
    },
  );
}
