import 'dart:collection';
import 'engine.dart';

void _version(String id, DateTime date) {
  if (id.isEmpty ||
      id.length > 80 ||
      !date.isUtc ||
      date.year < 1970 ||
      date.year > 2100 ||
      date != DateTime.utc(date.year, date.month, date.day)) {
    throw ArgumentError('Rule versions require an ID and UTC civil midnight');
  }
}

class SalaryRuleVersion {
  SalaryRuleVersion({
    required this.id,
    required this.effectiveFrom,
    required this.monthlyMinor,
    this.basis = SalaryBasis.annual,
  }) {
    _version(id, effectiveFrom);
    if (monthlyMinor < BigInt.zero) {
      throw ArgumentError('Negative monthly budget');
    }
  }
  final String id;
  final DateTime effectiveFrom;
  final BigInt monthlyMinor;
  final SalaryBasis basis;
}

class ScheduleRuleVersion {
  ScheduleRuleVersion({
    required this.id,
    required this.effectiveFrom,
    required this.template,
  }) {
    _version(id, effectiveFrom);
  }
  final String id;
  final DateTime effectiveFrom;

  /// The template contributes only time-domain/schedule fields, not its salary.
  final EarningsPolicy template;
}

/// Versions split queries, never the complete-period budget denominator.
/// Compiled salary/schedule combinations have an LRU cap independent of history.
class VersionedEarningsEngine extends EarningsEngine {
  VersionedEarningsEngine({
    required EarningsPolicy initial,
    required List<SalaryRuleVersion> salaries,
    required List<ScheduleRuleVersion> schedules,
  }) : salaries = List.unmodifiable(salaries),
       schedules = List.unmodifiable(schedules),
       super(initial) {
    _validate(this.salaries.map((v) => (v.id, v.effectiveFrom)).toList());
    _validate(this.schedules.map((v) => (v.id, v.effectiveFrom)).toList());
    if (this.salaries.first.effectiveFrom.isAfter(initial.startDate) ||
        this.schedules.first.effectiveFrom.isAfter(initial.startDate)) {
      throw ArgumentError('Initial rule history must cover employment start');
    }
    if (this.schedules.any(
      (v) => v.template.utcOffsetMinutes != initial.utcOffsetMinutes,
    )) {
      throw ArgumentError('Changing work timezone needs a separate migration');
    }
    _boundaries = {
      ...this.salaries.map((v) => v.effectiveFrom),
      ...this.schedules.map((v) => v.effectiveFrom),
    }.toList()..sort();
    _salaryDates = this.salaries
        .map((v) => v.effectiveFrom)
        .toList(growable: false);
    _scheduleDates = this.schedules
        .map((v) => v.effectiveFrom)
        .toList(growable: false);
  }
  final List<SalaryRuleVersion> salaries;
  final List<ScheduleRuleVersion> schedules;
  late final List<DateTime> _boundaries;
  late final List<DateTime> _salaryDates, _scheduleDates;
  final _compiled = LinkedHashMap<String, EarningsEngine>();
  static void _validate(List<(String, DateTime)> values) {
    if (values.isEmpty || values.length > 128) {
      throw ArgumentError('Expected 1–128 rule versions');
    }
    final ids = <String>{};
    for (var i = 0; i < values.length; i++) {
      if (!ids.add(values[i].$1) ||
          (i > 0 && !values[i].$2.isAfter(values[i - 1].$2))) {
        throw ArgumentError('Duplicate IDs, dates or unordered history');
      }
    }
  }

  int _index(List<DateTime> dates, DateTime civil) {
    var low = 0, high = dates.length;
    while (low < high) {
      final mid = (low + high) ~/ 2;
      if (dates[mid].isAfter(civil)) {
        high = mid;
      } else {
        low = mid + 1;
      }
    }
    return low - 1;
  }

  (SalaryRuleVersion, ScheduleRuleVersion, EarningsEngine) _at(DateTime civil) {
    final salary =
        salaries[_index(_salaryDates, civil).clamp(0, salaries.length - 1)];
    final schedule =
        schedules[_index(_scheduleDates, civil).clamp(0, schedules.length - 1)];
    final key = '${salary.id}|${schedule.id}';
    var engine = _compiled.remove(key);
    if (engine == null) {
      final t = schedule.template;
      engine = EarningsEngine(
        EarningsPolicy(
          monthlyMinor: salary.monthlyMinor,
          startDate: policy.startDate,
          basis: salary.basis,
          mode: t.mode,
          utcOffsetMinutes: policy.utcOffsetMinutes,
          weekdays: t.weekdays,
          spans: t.spans,
          dateOverrides: t.dateOverrides,
          shiftAttribution: t.shiftAttribution,
          anchoredSpans: t.anchoredSpans,
          calendarVersion: t.calendarVersion,
          calendarSourceDigest: t.calendarSourceDigest,
        ),
      );
    }
    _compiled[key] = engine;
    if (_compiled.length > 4) _compiled.remove(_compiled.keys.first);
    return (salary, schedule, engine);
  }

  @override
  EarningsPolicy policyAt(DateTime instant) =>
      _at(civilTime(instant)).$3.policy;
  @override
  int eligibleMilliseconds(DateTime instant) =>
      _at(civilTime(instant)).$3.eligibleMilliseconds(instant);
  @override
  Money ratePerSecond(DateTime instant) =>
      _at(civilTime(instant)).$3.ratePerSecond(instant);
  Money _query(DateTime start, DateTime end, List<CalculationSegment>? output) {
    if (!start.isUtc ||
        !end.isUtc ||
        end.isAfter(DateTime.utc(2101)) ||
        start.year < 1970) {
      throw ArgumentError('Supported UTC civil range: 1970–2100');
    }
    if (start.isBefore(policy.startDate)) start = policy.startDate;
    var cursor = start, total = Money.zero;
    while (cursor.isBefore(end)) {
      final (salary, schedule, engine) = _at(cursor);
      final nextIndex = _index(_boundaries, cursor) + 1;
      final next = nextIndex < _boundaries.length
          ? _boundaries[nextIndex]
          : end;
      final stop = next.isBefore(end) ? next : end;
      if (output == null) {
        total += engine.betweenCivil(cursor, stop);
      } else {
        for (final part in engine.traceBetweenCivil(cursor, stop)) {
          total += part.amount;
          output.add(
            CalculationSegment(
              start: part.start,
              end: part.end,
              amount: part.amount,
              budget: part.budget,
              numeratorMs: part.numeratorMs,
              denominatorMs: part.denominatorMs,
              salaryRuleId: salary.id,
              scheduleRuleId: schedule.id,
              utcOffsetMinutes: part.utcOffsetMinutes,
              calendarVersion: part.calendarVersion,
              calendarSourceDigest: part.calendarSourceDigest,
            ),
          );
        }
      }
      cursor = stop;
    }
    return total;
  }

  @override
  Money betweenCivil(DateTime start, DateTime end) => _query(start, end, null);
  @override
  List<CalculationSegment> traceBetweenCivil(DateTime start, DateTime end) {
    final result = <CalculationSegment>[];
    _query(start, end, result);
    return List.unmodifiable(result);
  }
}
