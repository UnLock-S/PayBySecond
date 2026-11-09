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
  }) : startDate = DateTime.utc(startDate.year, startDate.month, startDate.day),
       weekdays = Set.unmodifiable(weekdays),
       spans = List.unmodifiable(spans),
       dateOverrides = Map.unmodifiable(dateOverrides) {
    if (monthlyMinor < BigInt.zero)
      throw ArgumentError('Salary cannot be negative');
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

  Money betweenCivil(DateTime start, DateTime end) {
    if (!start.isUtc || !end.isUtc) {
      throw ArgumentError('Civil components must use DateTime.utc');
    }
    if (start.isBefore(policy.startDate)) start = policy.startDate;
    if (!end.isAfter(start)) return Money.zero;
    if (end.year > 2101 || start.year < 1970) {
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
      if (denominator > 0) {
        final numerator = _elapsed(cursor, stop, year);
        total += Money(
          policy.monthlyMinor *
              BigInt.from(annual ? 12 : 1) *
              BigInt.from(numerator),
          BigInt.from(100) * BigInt.from(denominator),
        );
      }
      cursor = stop;
    }
    return total;
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
      final working =
          policy.dateOverrides[EarningsPolicy.dateKey(date)] ??
          policy.weekdays.contains(date.weekday);
      final spans = policy.mode == AccrualMode.calendar
          ? const [WorkSpan(0, 1440)]
          : working
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
