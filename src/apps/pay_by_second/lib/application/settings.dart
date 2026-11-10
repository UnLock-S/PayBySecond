import 'package:earnings_core/earnings_core.dart';
import 'dart:convert';

part 'profile_document.dart';

class WorkInterval {
  WorkInterval(this.start, this.end) {
    if (start < 0 || start >= 1440 || end < 0 || end > 1440 || start == end) {
      throw const FormatException('Invalid work/break interval');
    }
  }
  final int start, end;
  List<int> toJson() => [start, end];
  factory WorkInterval.fromJson(Object? json) {
    if (json is! List ||
        json.length != 2 ||
        json[0] is! int ||
        json[1] is! int) {
      throw const FormatException('Expected two minute values');
    }
    return WorkInterval(json[0] as int, json[1] as int);
  }
}

class Settings {
  Settings({
    required this.salary,
    required DateTime start,
    this.mode = AccrualMode.calendar,
    this.basis = SalaryBasis.annual,
    Set<int> weekdays = const {1, 2, 3, 4, 5},
    this.startMinute = 480,
    this.endMinute = 1020,
    this.lunch = true,
    this.refreshMs = 1000,
    this.digits = 4,
    Map<String, bool> overrides = const {},
    this.shiftAttribution = ShiftAttribution.calendarDate,
    List<WorkInterval> intervals = const [],
    List<WorkInterval> breaks = const [],
    Map<String, bool> policyOverrides = const {},
    this.calendarVersion,
    Map<String, dynamic> calendarSource = const {},
    this.document,
    this.viewDate,
    this.effectiveFrom,
    this.migrationPending = false,
    this.salaryVersionRequested = false,
    this.scheduleVersionRequested = false,
  }) : start = DateTime.utc(start.year, start.month, start.day),
       weekdays = Set.unmodifiable(weekdays),
       overrides = Map.unmodifiable(overrides),
       policyOverrides = Map.unmodifiable(policyOverrides),
       intervals = List.unmodifiable(intervals),
       breaks = List.unmodifiable(breaks),
       calendarSource = _freezeMap(calendarSource);
  final String salary;
  final DateTime start;
  final AccrualMode mode;
  final SalaryBasis basis;
  final Set<int> weekdays;
  final int startMinute, endMinute, refreshMs, digits;
  final bool lunch;
  final Map<String, bool> overrides;
  final ShiftAttribution shiftAttribution;
  final List<WorkInterval> intervals, breaks;
  final Map<String, bool> policyOverrides;
  final String? calendarVersion;
  final Map<String, dynamic> calendarSource;
  final ProfileDocument? document;
  final DateTime? viewDate, effectiveFrom;
  final bool migrationPending;
  final bool salaryVersionRequested, scheduleVersionRequested;

  Settings copyWith({
    String? salary,
    DateTime? start,
    AccrualMode? mode,
    SalaryBasis? basis,
    Set<int>? weekdays,
    int? startMinute,
    int? endMinute,
    bool? lunch,
    int? refreshMs,
    int? digits,
    Map<String, bool>? overrides,
    ShiftAttribution? shiftAttribution,
    List<WorkInterval>? intervals,
    List<WorkInterval>? breaks,
    Map<String, bool>? policyOverrides,
    String? calendarVersion,
    Map<String, dynamic>? calendarSource,
    ProfileDocument? document,
    DateTime? viewDate,
    DateTime? effectiveFrom,
    bool? migrationPending,
    bool? salaryVersionRequested,
    bool? scheduleVersionRequested,
  }) => Settings(
    salary: salary ?? this.salary,
    start: start ?? this.start,
    mode: mode ?? this.mode,
    basis: basis ?? this.basis,
    weekdays: weekdays ?? this.weekdays,
    startMinute: startMinute ?? this.startMinute,
    endMinute: endMinute ?? this.endMinute,
    lunch: lunch ?? this.lunch,
    refreshMs: refreshMs ?? this.refreshMs,
    digits: digits ?? this.digits,
    overrides: overrides ?? this.overrides,
    shiftAttribution: shiftAttribution ?? this.shiftAttribution,
    intervals: intervals ?? this.intervals,
    breaks: breaks ?? this.breaks,
    policyOverrides: policyOverrides ?? this.policyOverrides,
    calendarVersion: calendarVersion ?? this.calendarVersion,
    calendarSource: calendarSource ?? this.calendarSource,
    document: document ?? this.document,
    viewDate: viewDate ?? this.viewDate,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    migrationPending: migrationPending ?? this.migrationPending,
    salaryVersionRequested:
        salaryVersionRequested ?? this.salaryVersionRequested,
    scheduleVersionRequested:
        scheduleVersionRequested ?? this.scheduleVersionRequested,
  );

  EarningsPolicy toPolicy() {
    if (!RegExp(r'^\d{1,10}(\.\d{1,2})?$').hasMatch(salary)) {
      throw const FormatException('月薪请输入非负金额，最多两位小数');
    }
    final parts = salary.split('.');
    final minor =
        BigInt.parse(parts[0]) * BigInt.from(100) +
        BigInt.parse(parts.length == 1 ? '0' : parts[1].padRight(2, '0'));
    if (![100, 1000].contains(refreshMs) || ![2, 4, 6].contains(digits)) {
      throw const FormatException('显示设置无效');
    }
    if (startMinute < 0 ||
        startMinute >= 1440 ||
        endMinute < 0 ||
        endMinute > 1440 ||
        startMinute == endMinute) {
      throw const FormatException('工作时间不能为空或相同');
    }
    if (intervals.length > 16 || breaks.length > 16) {
      throw const FormatException('Too many schedule intervals');
    }
    if (calendarSource.isNotEmpty) {
      PolicySource.fromJson(calendarSource['source'] as Map<String, dynamic>);
      if (calendarSource['version'] != calendarVersion ||
          !RegExp(
            r'^[0-9a-f]{64}$',
          ).hasMatch(calendarSource['datasetSha256'] as String)) {
        throw const FormatException('Invalid calendar source snapshot');
      }
      _utcCreated(calendarSource['personalReviewedAt']);
    }
    final working = intervals.isEmpty
        ? [WorkInterval(startMinute, endMinute)]
        : intervals;
    final resting = [...breaks, if (lunch) WorkInterval(720, 780)];
    final anchored = <AnchoredWorkSpan>[];
    for (final interval in working) {
      var pieces = [
        (
          interval.start,
          interval.end > interval.start ? interval.end : interval.end + 1440,
        ),
      ];
      for (final rest in resting) {
        final durationEnd = rest.end > rest.start ? rest.end : rest.end + 1440;
        for (final offset in [-1440, 0, 1440]) {
          final result = <(int, int)>[];
          for (final piece in pieces) {
            final a = rest.start + offset, b = durationEnd + offset;
            if (b <= piece.$1 || a >= piece.$2) {
              result.add(piece);
              continue;
            }
            if (piece.$1 < a) result.add((piece.$1, a));
            if (b < piece.$2) result.add((b, piece.$2));
          }
          pieces = result;
        }
      }
      anchored.addAll(pieces.map((p) => AnchoredWorkSpan(p.$1, p.$2)));
    }
    final paid = <WorkSpan>[];
    for (final span in anchored) {
      if (span.startMinute < 1440) {
        paid.add(WorkSpan(span.startMinute, span.endMinute.clamp(0, 1440)));
      }
      if (span.endMinute > 1440) {
        paid.add(
          WorkSpan(
            (span.startMinute - 1440).clamp(0, 1440),
            span.endMinute - 1440,
          ),
        );
      }
    }
    return EarningsPolicy(
      monthlyMinor: minor,
      startDate: start,
      mode: mode,
      basis: basis,
      weekdays: weekdays,
      spans: paid,
      dateOverrides: {...policyOverrides, ...overrides},
      anchoredSpans: anchored,
      shiftAttribution: shiftAttribution,
      calendarVersion: calendarVersion ?? 'personal-weekly',
      calendarSourceDigest: calendarSource['datasetSha256'] as String?,
    );
  }

  EarningsEngine toEngine() => document?.engine() ?? EarningsEngine(toPolicy());

  Map<String, Object> toJson() => {
    'schemaVersion': 1,
    'salary': salary,
    'start': EarningsPolicy.dateKey(start),
    'mode': mode.name,
    'basis': basis.name,
    'weekdays': weekdays.toList(),
    'startMinute': startMinute,
    'endMinute': endMinute,
    'lunch': lunch,
    'refreshMs': refreshMs,
    'digits': digits,
    'overrides': overrides,
    if (shiftAttribution != ShiftAttribution.calendarDate)
      'shiftAttribution': shiftAttribution.name,
    if (intervals.isNotEmpty)
      'intervals': intervals.map((v) => v.toJson()).toList(),
    if (breaks.isNotEmpty) 'breaks': breaks.map((v) => v.toJson()).toList(),
    if (policyOverrides.isNotEmpty) 'policyOverrides': policyOverrides,
    'calendarVersion': ?calendarVersion,
    if (calendarSource.isNotEmpty) 'calendarSource': calendarSource,
  };

  factory Settings.fromJson(Map<String, dynamic> data) {
    if (data['schemaVersion'] != 1) throw const FormatException('无法读取此版本配置');
    final storedDate = data['start'];
    final parsedDate = storedDate is String
        ? DateTime.tryParse(storedDate)
        : null;
    if (parsedDate == null ||
        EarningsPolicy.dateKey(parsedDate) != storedDate) {
      throw const FormatException('Invalid employment calendar date');
    }
    final s = Settings(
      salary: data['salary'] as String,
      start: parsedDate,
      mode: AccrualMode.values.byName(data['mode'] as String),
      basis: SalaryBasis.values.byName(data['basis'] as String),
      weekdays: (data['weekdays'] as List).cast<int>().toSet(),
      startMinute: data['startMinute'] as int,
      endMinute: data['endMinute'] as int,
      lunch: data['lunch'] as bool,
      refreshMs: data['refreshMs'] as int,
      digits: data['digits'] as int,
      overrides: (data['overrides'] as Map).cast<String, bool>(),
      shiftAttribution: data['shiftAttribution'] == null
          ? ShiftAttribution.calendarDate
          : ShiftAttribution.values.byName(data['shiftAttribution'] as String),
      intervals: (data['intervals'] as List? ?? [])
          .map(WorkInterval.fromJson)
          .toList(),
      breaks: (data['breaks'] as List? ?? [])
          .map(WorkInterval.fromJson)
          .toList(),
      policyOverrides: (data['policyOverrides'] as Map? ?? {})
          .cast<String, bool>(),
      calendarVersion: data['calendarVersion'] as String?,
      calendarSource:
          data['calendarSource'] as Map<String, dynamic>? ?? const {},
    );
    s.toPolicy();
    return s;
  }
}

abstract interface class SettingsRepository {
  Future<Settings?> load();
  Future<void> save(Settings settings);
  Future<void> clear();
}
