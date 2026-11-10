import 'dart:collection';

/// Exact rational money in yuan. Round only when formatting for display.
class Money {
  factory Money(BigInt numerator, BigInt denominator) {
    if (denominator <= BigInt.zero) {
      throw ArgumentError('Denominator must be positive');
    }
    final gcd = numerator.gcd(denominator);
    return Money._(numerator ~/ gcd, denominator ~/ gcd);
  }
  const Money._(this.numerator, this.denominator);
  static final zero = Money(BigInt.zero, BigInt.one);
  final BigInt numerator;
  final BigInt denominator;

  Money operator +(Money other) => Money(
    numerator * other.denominator + other.numerator * denominator,
    denominator * other.denominator,
  );
  Money scale(int value) => Money(numerator * BigInt.from(value), denominator);

  String format([int digits = 4]) {
    if (digits < 0 || digits > 6) throw RangeError.range(digits, 0, 6);
    final scale = BigInt.from(10).pow(digits);
    final rounded =
        (numerator.abs() * scale * BigInt.two + denominator) ~/
        (denominator * BigInt.two);
    final sign = numerator.isNegative && rounded != BigInt.zero ? '-' : '';
    final whole = rounded ~/ scale;
    if (digits == 0) return '$sign$whole';
    return '$sign$whole.${(rounded % scale).toString().padLeft(digits, '0')}';
  }
}

enum AccrualMode { calendar, work }

enum SalaryBasis { annual, monthly }

enum Period { employment, year, month, week, day, hour }

enum ShiftAttribution { calendarDate, shiftStartDate }

/// Paid interval relative to the logical shift's civil anchor date.
class AnchoredWorkSpan {
  AnchoredWorkSpan(this.startMinute, this.endMinute) {
    if (startMinute < 0 ||
        endMinute > 2880 ||
        startMinute >= endMinute ||
        endMinute - startMinute > 1440) {
      throw ArgumentError('Invalid anchored work interval');
    }
  }
  final int startMinute, endMinute;
}

class CalculationSegment {
  const CalculationSegment({
    required this.start,
    required this.end,
    required this.amount,
    required this.budget,
    required this.numeratorMs,
    required this.denominatorMs,
    this.salaryRuleId = 'current-salary',
    this.scheduleRuleId = 'current-schedule',
    this.utcOffsetMinutes = 480,
  });
  final DateTime start, end;
  final Money amount, budget;
  final int numeratorMs, denominatorMs;
  final int utcOffsetMinutes;
  final String salaryRuleId, scheduleRuleId;
  Map<String, Object> toJson() => {
    'amountType': 'simulated_accrual',
    'start': start
        .subtract(Duration(minutes: utcOffsetMinutes))
        .toIso8601String(),
    'end': end.subtract(Duration(minutes: utcOffsetMinutes)).toIso8601String(),
    'workUtcOffsetMinutes': utcOffsetMinutes,
    'salaryRuleId': salaryRuleId,
    'scheduleRuleId': scheduleRuleId,
    'formulaId': 'salary.budget.v1',
    'numeratorTimeMs': numeratorMs.toString(),
    'denominatorTimeMs': denominatorMs.toString(),
    'exactAmountMinorRational':
        '${amount.scale(100).numerator}/${amount.scale(100).denominator}',
    'roundingMode': 'half-away-from-zero-display-only',
    'displayAmount': amount.format(4),
  };
}

class WorkSpan {
  const WorkSpan(this.startMinute, this.endMinute);
  final int startMinute;
  final int endMinute;
}

/// Immutable fixed-offset policy. MVP deliberately supports UTC+08:00 only in UI.
/// Dates are represented as UTC civil components, not machine-local dates.
class EarningsPolicy {
  EarningsPolicy({
    required this.monthlyMinor,
    required DateTime startDate,
    this.mode = AccrualMode.calendar,
    this.basis = SalaryBasis.annual,
    this.utcOffsetMinutes = 480,
    Set<int> weekdays = const {1, 2, 3, 4, 5},
    List<WorkSpan> spans = const [WorkSpan(480, 720), WorkSpan(780, 1020)],
    Map<String, bool> dateOverrides = const {},
    this.shiftAttribution = ShiftAttribution.calendarDate,
    List<AnchoredWorkSpan> anchoredSpans = const [],
  }) : startDate = DateTime.utc(startDate.year, startDate.month, startDate.day),
       weekdays = Set.unmodifiable(weekdays),
       spans = List.unmodifiable(spans),
       dateOverrides = Map.unmodifiable(dateOverrides),
       anchoredSpans = List.unmodifiable(anchoredSpans) {
    if (monthlyMinor < BigInt.zero) {
      throw ArgumentError('Salary cannot be negative');
    }
    if (this.startDate.year < 1970 || this.startDate.year > 2100) {
      throw ArgumentError('Start year must be between 1970 and 2100');
    }
    if (utcOffsetMinutes < -720 || utcOffsetMinutes > 840) {
      throw ArgumentError('Invalid fixed UTC offset');
    }
    if (this.weekdays.any((d) => d < 1 || d > 7)) {
      throw ArgumentError('Invalid weekday');
    }
    for (final span in this.spans) {
      if (span.startMinute < 0 ||
          span.endMinute > 1440 ||
          span.startMinute >= span.endMinute) {
        throw ArgumentError(
          'Use nonempty same-day spans; split overnight shifts',
        );
      }
    }
    for (final key in this.dateOverrides.keys) {
      final parsed = DateTime.tryParse(key);
      if (parsed == null || dateKey(parsed) != key) {
        throw ArgumentError('Invalid override date: $key');
      }
    }
  }
  final BigInt monthlyMinor;
  final DateTime startDate;
  final AccrualMode mode;
  final SalaryBasis basis;
  final int utcOffsetMinutes;
  final Set<int> weekdays;
  final List<WorkSpan> spans;
  final Map<String, bool> dateOverrides;
  final ShiftAttribution shiftAttribution;
  final List<AnchoredWorkSpan> anchoredSpans;

  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _Year {
  _Year(this.prefix, this.spans);
  final List<int> prefix;
  final List<List<WorkSpan>> spans;
}

/// Reuse one engine per policy. Compiled daily calendars use an LRU capped at 3.
class EarningsEngine {
  EarningsEngine(this.policy);
  final EarningsPolicy policy;
  EarningsPolicy policyAt(DateTime instant) => policy;
  final _years = LinkedHashMap<int, _Year>();
  static const _dayMs = 86400000;
  static const _minuteMs = 60000;

  DateTime civilTime(DateTime instant) =>
      instant.toUtc().add(Duration(minutes: policy.utcOffsetMinutes));

  DateTime periodStart(Period period, DateTime instant) {
    final t = civilTime(instant);
    return switch (period) {
      Period.employment => policy.startDate,
      Period.year => DateTime.utc(t.year),
      Period.month => DateTime.utc(t.year, t.month),
      Period.week => DateTime.utc(
        t.year,
        t.month,
        t.day,
      ).subtract(Duration(days: t.weekday - 1)),
      Period.day => DateTime.utc(t.year, t.month, t.day),
      Period.hour => DateTime.utc(t.year, t.month, t.day, t.hour),
    };
  }

  Money earned(Period period, DateTime instant) =>
      betweenCivil(periodStart(period, instant), civilTime(instant));

  Money betweenCivil(DateTime start, DateTime end) =>
      _calculate(start, end, null);

  List<CalculationSegment> traceBetweenCivil(DateTime start, DateTime end) {
    final segments = <CalculationSegment>[];
    _calculate(start, end, segments);
    return List.unmodifiable(segments);
  }

  Money _calculate(
    DateTime start,
    DateTime end,
    List<CalculationSegment>? trace,
  ) {
    if (!start.isUtc || !end.isUtc) {
      throw ArgumentError('Civil components must use DateTime.utc');
    }
    if (start.isBefore(policy.startDate)) start = policy.startDate;
    if (!end.isAfter(start)) return Money.zero;
    if (end.isAfter(DateTime.utc(2101)) || start.year < 1970) {
      throw ArgumentError('Supported calculation range: 1970–2100');
    }
    var total = Money.zero;
    var cursor = start;
    while (cursor.isBefore(end)) {
      final annual = policy.basis == SalaryBasis.annual;
      final base = annual
          ? DateTime.utc(cursor.year)
          : DateTime.utc(cursor.year, cursor.month);
      final next = annual
          ? DateTime.utc(cursor.year + 1)
          : DateTime.utc(cursor.year, cursor.month + 1);
      final stop = end.isBefore(next) ? end : next;
      // A complete fixed-policy period earns its budget if it has any paid time.
      final year = _year(cursor.year);
      final denominator = _elapsed(base, next, year);
      final numerator = _elapsed(cursor, stop, year);
      final budget = trace == null
          ? Money.zero
          : Money(
              policy.monthlyMinor * BigInt.from(annual ? 12 : 1),
              BigInt.from(100),
            );
      var amount = Money.zero;
      if (denominator > 0) {
        amount = Money(
          policy.monthlyMinor *
              BigInt.from(annual ? 12 : 1) *
              BigInt.from(numerator),
          BigInt.from(100) * BigInt.from(denominator),
        );
        total += amount;
      }
      trace?.add(
        CalculationSegment(
          start: cursor,
          end: stop,
          amount: amount,
          budget: budget,
          numeratorMs: numerator,
          denominatorMs: denominator,
          utcOffsetMinutes: policy.utcOffsetMinutes,
        ),
      );
      cursor = stop;
    }
    return total;
  }

  int eligibleMilliseconds(DateTime instant) {
    final t = civilTime(instant), year = _year(civilTime(instant).year);
    return policy.basis == SalaryBasis.annual
        ? year.prefix.last
        : _elapsed(
            DateTime.utc(t.year, t.month),
            DateTime.utc(t.year, t.month + 1),
            year,
          );
  }

  Money ratePerSecond(DateTime instant) {
    final t = civilTime(instant);
    if (t.isBefore(policy.startDate)) return Money.zero;
    final year = _year(t.year);
    final index = DateTime.utc(
      t.year,
      t.month,
      t.day,
    ).difference(DateTime.utc(t.year)).inDays;
    final ms = t
        .difference(DateTime.utc(t.year, t.month, t.day))
        .inMilliseconds;
    if (!year.spans[index].any(
      (s) => ms >= s.startMinute * _minuteMs && ms < s.endMinute * _minuteMs,
    )) {
      return Money.zero;
    }
    final annual = policy.basis == SalaryBasis.annual;
    final denominator = annual
        ? year.prefix.last
        : _elapsed(
            DateTime.utc(t.year, t.month),
            DateTime.utc(t.year, t.month + 1),
            year,
          );
    if (denominator == 0) return Money.zero;
    return Money(
      policy.monthlyMinor * BigInt.from(annual ? 12000 : 1000),
      BigInt.from(100) * BigInt.from(denominator),
    );
  }

  int _elapsed(DateTime start, DateTime end, _Year year) =>
      _position(end, start.year, year) - _position(start, start.year, year);

  int _position(DateTime time, int yearNumber, _Year year) {
    final offset = time.difference(DateTime.utc(yearNumber)).inMilliseconds;
    final day = offset ~/ _dayMs;
    if (day >= year.spans.length) return year.prefix.last;
    final within = offset % _dayMs;
    var result = year.prefix[day];
    for (final s in year.spans[day]) {
      result += (within - s.startMinute * _minuteMs).clamp(
        0,
        (s.endMinute - s.startMinute) * _minuteMs,
      );
    }
    return result;
  }

  _Year _year(int number) {
    final cached = _years.remove(number);
    if (cached != null) {
      _years[number] = cached;
      return cached;
    }
    final days = DateTime.utc(
      number + 1,
    ).difference(DateTime.utc(number)).inDays;
    final prefix = <int>[0];
    final schedule = <List<WorkSpan>>[];
    final sorted = [...policy.spans]
      ..sort((a, b) => a.startMinute.compareTo(b.startMinute));
    final merged = <WorkSpan>[];
    for (final s in sorted) {
      if (merged.isNotEmpty && s.startMinute <= merged.last.endMinute) {
        final previous = merged.removeLast();
        merged.add(
          WorkSpan(
            previous.startMinute,
            s.endMinute > previous.endMinute ? s.endMinute : previous.endMinute,
          ),
        );
      } else {
        merged.add(s);
      }
    }
    for (var i = 0; i < days; i++) {
      final date = DateTime.utc(number, 1, 1 + i);
      bool working(DateTime anchor) =>
          policy.dateOverrides[EarningsPolicy.dateKey(anchor)] ??
          policy.weekdays.contains(anchor.weekday);
      final anchored = <WorkSpan>[];
      if (policy.mode == AccrualMode.work &&
          policy.shiftAttribution == ShiftAttribution.shiftStartDate) {
        final templates = policy.anchoredSpans.isEmpty
            ? policy.spans
                  .map((s) => AnchoredWorkSpan(s.startMinute, s.endMinute))
                  .toList()
            : policy.anchoredSpans;
        for (final offset in [0, 1440]) {
          if (!working(date.subtract(Duration(minutes: offset)))) continue;
          for (final span in templates) {
            final begin = (span.startMinute - offset).clamp(0, 1440);
            final finish = (span.endMinute - offset).clamp(0, 1440);
            if (begin < finish) anchored.add(WorkSpan(begin, finish));
          }
        }
        anchored.sort((a, b) => a.startMinute.compareTo(b.startMinute));
        for (var n = 1; n < anchored.length;) {
          if (anchored[n].startMinute <= anchored[n - 1].endMinute) {
            final previous = anchored[n - 1], current = anchored.removeAt(n);
            anchored[n - 1] = WorkSpan(
              previous.startMinute,
              current.endMinute > previous.endMinute
                  ? current.endMinute
                  : previous.endMinute,
            );
          } else {
            n++;
          }
        }
      }
      final spans = policy.mode == AccrualMode.calendar
          ? const [WorkSpan(0, 1440)]
          : policy.shiftAttribution == ShiftAttribution.shiftStartDate
          ? anchored
          : working(date)
          ? merged
          : <WorkSpan>[];
      schedule.add(spans);
      prefix.add(
        prefix.last +
            spans.fold<int>(
              0,
              (v, s) => v + (s.endMinute - s.startMinute) * _minuteMs,
            ),
      );
    }
    final compiled = _Year(prefix, schedule);
    _years[number] = compiled;
    if (_years.length > 3) _years.remove(_years.keys.first);
    return compiled;
  }
}
