import 'engine.dart';

enum OvertimePay { unpaid, statutory, single, custom }

enum OvertimeDay { weekday, rest, holiday }

/// A per-session snapshot; changing salary/defaults never rewrites history.
class OvertimePolicy {
  OvertimePolicy({
    required this.monthlyMinor,
    this.pay = OvertimePay.unpaid,
    this.day = OvertimeDay.weekday,
    this.multiplier = 150,
    this.compensatoryLeave = false,
  }) {
    if (monthlyMinor < BigInt.zero ||
        monthlyMinor > BigInt.parse('999999999999') ||
        multiplier < 1 ||
        multiplier > 10000) {
      throw ArgumentError('Invalid overtime policy');
    }
  }
  final BigInt monthlyMinor;
  final OvertimePay pay;
  final OvertimeDay day;

  /// Hundredths: 150 means 1.5 times the hourly base.
  final int multiplier;
  final bool compensatoryLeave;
  int get statutoryMultiplier => switch (day) {
    OvertimeDay.weekday => 150,
    OvertimeDay.rest => compensatoryLeave ? 0 : 200,
    OvertimeDay.holiday => 300,
  };
  int get expectedMultiplier => switch (pay) {
    OvertimePay.unpaid => 0,
    OvertimePay.statutory => statutoryMultiplier,
    OvertimePay.single => 100,
    OvertimePay.custom => multiplier,
  };
  Money amount(Duration elapsed, int factor) {
    final micros = elapsed.isNegative ? 0 : elapsed.inMicroseconds;
    // minor currency / 100 / 174 hours / 3600 seconds / 1e6 / 100 multiplier.
    return Money(
      monthlyMinor * BigInt.from(micros) * BigInt.from(factor),
      BigInt.from(100) *
          BigInt.from(174) *
          BigInt.from(3600000000) *
          BigInt.from(100),
    );
  }

  Money expected(Duration elapsed) => amount(elapsed, expectedMultiplier);
  Money statutory(Duration elapsed) => amount(elapsed, statutoryMultiplier);

  /// Humorous unpaid-time value uses 1x; never represents a payroll deduction.
  Money unpaidValue(Duration elapsed) =>
      amount(elapsed, pay == OvertimePay.unpaid ? 100 : 0);
  Map<String, dynamic> toJson() => {
    'base': monthlyMinor.toString(),
    'pay': pay.name,
    'day': day.name,
    'multiplier': multiplier,
    'compensatoryLeave': compensatoryLeave,
  };
  factory OvertimePolicy.fromJson(Map<String, dynamic> json) => OvertimePolicy(
    monthlyMinor: BigInt.parse(json['base'] as String),
    pay: OvertimePay.values.byName(json['pay'] as String),
    day: OvertimeDay.values.byName(json['day'] as String),
    multiplier: json['multiplier'] as int,
    compensatoryLeave: json['compensatoryLeave'] as bool,
  );
}

class OvertimeEntry {
  OvertimeEntry({
    required this.id,
    required DateTime start,
    DateTime? end,
    required this.policy,
  }) : start = start.toUtc(),
       end = end?.toUtc() {
    if (id < 1 || (this.end != null && this.end!.isBefore(this.start))) {
      throw ArgumentError('Invalid overtime interval');
    }
  }
  final int id;
  final DateTime start;
  final DateTime? end;
  final OvertimePolicy policy;
  Duration elapsed(DateTime now) {
    final value = (end ?? now.toUtc()).difference(start);
    return value.isNegative ? Duration.zero : value;
  }

  OvertimeEntry stop(DateTime now) =>
      OvertimeEntry(id: id, start: start, end: now, policy: policy);
  Map<String, dynamic> toJson() => {
    'id': id,
    'start': start.toIso8601String(),
    'end': end?.toIso8601String(),
    'policy': policy.toJson(),
  };
  factory OvertimeEntry.fromJson(Map<String, dynamic> json) {
    DateTime instant(String text) {
      final date = DateTime.parse(text);
      if (!date.isUtc || date.year < 1970 || date.year > 2100) {
        throw FormatException('UTC timestamp required');
      }
      return date;
    }

    return OvertimeEntry(
      id: json['id'] as int,
      start: instant(json['start'] as String),
      end: json['end'] == null ? null : instant(json['end'] as String),
      policy: OvertimePolicy.fromJson(json['policy'] as Map<String, dynamic>),
    );
  }
}
