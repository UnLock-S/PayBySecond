import 'package:earnings_core/earnings_core.dart';

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
  }) : start = DateTime.utc(start.year, start.month, start.day),
       weekdays = Set.unmodifiable(weekdays),
       overrides = Map.unmodifiable(overrides);
  final String salary;
  final DateTime start;
  final AccrualMode mode;
  final SalaryBasis basis;
  final Set<int> weekdays;
  final int startMinute, endMinute, refreshMs, digits;
  final bool lunch;
  final Map<String, bool> overrides;

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
    final spans = startMinute < endMinute
        ? [WorkSpan(startMinute, endMinute)]
        : [
            WorkSpan(0, endMinute),
            WorkSpan(startMinute, 1440),
          ].where((s) => s.startMinute < s.endMinute).toList();
    final paid = <WorkSpan>[];
    for (final s in spans) {
      if (!lunch || s.endMinute <= 720 || s.startMinute >= 780) {
        paid.add(s);
      } else {
        if (s.startMinute < 720) paid.add(WorkSpan(s.startMinute, 720));
        if (s.endMinute > 780) paid.add(WorkSpan(780, s.endMinute));
      }
    }
    return EarningsPolicy(
      monthlyMinor: minor,
      startDate: start,
      mode: mode,
      basis: basis,
      weekdays: weekdays,
      spans: paid,
      dateOverrides: overrides,
    );
  }

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
