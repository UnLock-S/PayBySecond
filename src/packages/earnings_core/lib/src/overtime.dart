import 'engine.dart';
import 'policy.dart';

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
    this.referenceVersion = 'legacy-unverified',
    this.standardHoursConfirmed = false,
    this.employerArranged = false,
    this.sourceReviewedAt,
    this.classificationDate,
  }) {
    if (monthlyMinor < BigInt.zero ||
        monthlyMinor > BigInt.parse('999999999999') ||
        multiplier < 1 ||
        multiplier > 10000) {
      throw ArgumentError('Invalid overtime policy');
    }
    if (referenceVersion != 'legacy-unverified' &&
        referenceVersion != cnStandard2025['id']) {
      throw ArgumentError('Unsupported overtime reference');
    }
    if (classificationDate != null) {
      final date = DateTime.tryParse(classificationDate!);
      if (date == null ||
          EarningsPolicy.dateKey(date) != classificationDate ||
          date.year < 1970 ||
          date.year > 2100) {
        throw ArgumentError('Invalid classification date');
      }
    }
    if (sourceReviewedAt != null && !sourceReviewedAt!.isUtc) {
      throw ArgumentError('UTC review time required');
    }
  }
  final BigInt monthlyMinor;
  final OvertimePay pay;
  final OvertimeDay day;

  /// Hundredths: 150 means 1.5 times the hourly base.
  final int multiplier;
  final bool compensatoryLeave;
  final String referenceVersion;
  final bool standardHoursConfirmed, employerArranged;
  final DateTime? sourceReviewedAt;
  final String? classificationDate;
  bool get legacy => referenceVersion == 'legacy-unverified';
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
          BigInt.parse(cnStandard2025['hourDivisor']!) *
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
    if (!legacy) ...{
      'referenceVersion': referenceVersion,
      'standardHoursConfirmed': standardHoursConfirmed,
      'employerArranged': employerArranged,
      'sourceReviewedAt': sourceReviewedAt?.toIso8601String(),
      'classificationDate': classificationDate,
      'source': cnStandard2025,
    },
  };
  factory OvertimePolicy.fromJson(Map<String, dynamic> json) => OvertimePolicy(
    monthlyMinor: BigInt.parse(json['base'] as String),
    pay: OvertimePay.values.byName(json['pay'] as String),
    day: OvertimeDay.values.byName(json['day'] as String),
    multiplier: json['multiplier'] as int,
    compensatoryLeave: json['compensatoryLeave'] as bool,
    referenceVersion:
        json['referenceVersion'] as String? ?? 'legacy-unverified',
    standardHoursConfirmed: json['standardHoursConfirmed'] as bool? ?? false,
    employerArranged: json['employerArranged'] as bool? ?? false,
    sourceReviewedAt: json['sourceReviewedAt'] == null
        ? null
        : DateTime.parse(json['sourceReviewedAt'] as String),
    classificationDate: json['classificationDate'] as String?,
  );
}

class OvertimeEntry {
  OvertimeEntry({
    required this.id,
    required DateTime start,
    DateTime? end,
    required this.policy,
    this.correctedAt,
    List<String> previousEnds = const [],
  }) : start = start.toUtc(),
       end = end?.toUtc(),
       previousEnds = List.unmodifiable(previousEnds) {
    if (id < 1 ||
        this.start.year < 1970 ||
        this.start.year > 2100 ||
        (this.end != null &&
            (this.end!.year < 1970 ||
                this.end!.year > 2100 ||
                this.end!.isBefore(this.start)))) {
      throw ArgumentError('Invalid overtime interval');
    }
    if (previousEnds.length > 32 ||
        (correctedAt != null && !correctedAt!.isUtc)) {
      throw ArgumentError('Invalid correction metadata');
    }
  }
  final int id;
  final DateTime start;
  final DateTime? end;
  final OvertimePolicy policy;
  final DateTime? correctedAt;
  final List<String> previousEnds;
  Duration elapsed(DateTime now) {
    final value = (end ?? now.toUtc()).difference(start);
    return value.isNegative ? Duration.zero : value;
  }

  OvertimeEntry stop(DateTime now) =>
      OvertimeEntry(id: id, start: start, end: now, policy: policy);
  OvertimeEntry correctEnd(DateTime value, DateTime now) => OvertimeEntry(
    id: id,
    start: start,
    end: value,
    policy: policy,
    correctedAt: now.toUtc(),
    previousEnds: [...previousEnds, if (end != null) end!.toIso8601String()],
  );
  OvertimeReference reference(DateTime now) {
    final elapsedTime = elapsed(now);
    if (policy.legacy) {
      return OvertimeReference(
        policy.statutory(elapsedTime),
        Duration.zero,
        policy.compensatoryLeave && policy.day == OvertimeDay.rest
            ? elapsedTime
            : Duration.zero,
      );
    }
    final stop = end ?? now.toUtc();
    if (!policy.standardHoursConfirmed ||
        !policy.employerArranged ||
        policy.sourceReviewedAt == null ||
        policy.classificationDate == null) {
      return OvertimeReference(Money.zero, elapsedTime, Duration.zero);
    }
    final parsedDay = DateTime.parse(policy.classificationDate!);
    final day = DateTime.utc(parsedDay.year, parsedDay.month, parsedDay.day);
    if (day.isBefore(DateTime.utc(2025))) {
      return OvertimeReference(Money.zero, elapsedTime, Duration.zero);
    }
    final dayStart = day.subtract(const Duration(hours: 8)),
        dayEnd = day
            .add(const Duration(days: 1))
            .subtract(const Duration(hours: 8));
    final a = start.isAfter(dayStart) ? start : dayStart,
        b = stop.isBefore(dayEnd) ? stop : dayEnd;
    final knownDuration = b.isAfter(a) ? b.difference(a) : Duration.zero;
    return OvertimeReference(
      policy.statutory(knownDuration),
      elapsedTime - knownDuration,
      policy.day == OvertimeDay.rest && policy.compensatoryLeave
          ? knownDuration
          : Duration.zero,
    );
  }

  Money expectedAt(DateTime now) => policy.pay == OvertimePay.statutory
      ? reference(now).knownCash
      : policy.expected(elapsed(now));
  Map<String, dynamic> toJson() => {
    'id': id,
    'start': start.toIso8601String(),
    'end': end?.toIso8601String(),
    'policy': policy.toJson(),
    if (correctedAt != null) ...{
      'correctedAt': correctedAt!.toIso8601String(),
      'correctionReason': 'end-time-correction',
      'previousEnds': previousEnds,
    },
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
      correctedAt: json['correctedAt'] == null
          ? null
          : instant(json['correctedAt'] as String),
      previousEnds: (json['previousEnds'] as List? ?? const []).cast<String>(),
    );
  }
}

class OvertimeReference {
  const OvertimeReference(
    this.knownCash,
    this.pendingDuration,
    this.compensatoryDuration,
  );
  final Money knownCash;
  final Duration pendingDuration, compensatoryDuration;
}
