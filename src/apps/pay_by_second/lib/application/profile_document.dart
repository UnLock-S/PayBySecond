part of 'settings.dart';

DateTime profileDate(String text) {
  final parsed = DateTime.tryParse(text);
  if (parsed == null ||
      EarningsPolicy.dateKey(parsed) != text ||
      parsed.year < 1970 ||
      parsed.year > 2100) {
    throw const FormatException('Invalid effective calendar date');
  }
  return DateTime.utc(parsed.year, parsed.month, parsed.day);
}

DateTime _utcCreated(Object? value) {
  final date = DateTime.parse(value as String);
  if (!date.isUtc) throw const FormatException('UTC metadata required');
  return date;
}

class SalaryRecord {
  SalaryRecord({
    required this.id,
    required this.from,
    required this.createdAt,
    required this.salary,
    required this.basis,
  });
  final String id, salary;
  final DateTime from, createdAt;
  final SalaryBasis basis;
  BigInt get minor =>
      Settings(salary: salary, start: from).toPolicy().monthlyMinor;
  SalaryRuleVersion toCore() => SalaryRuleVersion(
    id: id,
    effectiveFrom: from,
    monthlyMinor: minor,
    basis: basis,
  );
  Map<String, Object> toJson() => {
    'id': id,
    'effectiveFrom': EarningsPolicy.dateKey(from),
    'createdAt': createdAt.toIso8601String(),
    'salary': salary,
    'basis': basis.name,
  };
  factory SalaryRecord.fromJson(Map<String, dynamic> j) => SalaryRecord(
    id: j['id'] as String,
    from: profileDate(j['effectiveFrom'] as String),
    createdAt: _utcCreated(j['createdAt']),
    salary: j['salary'] as String,
    basis: SalaryBasis.values.byName(j['basis'] as String),
  );
}

class ScheduleRecord {
  ScheduleRecord({
    required this.id,
    required this.from,
    required this.createdAt,
    required Map<String, dynamic> fields,
  }) : fields = _freezeMap(fields);
  final String id;
  final DateTime from, createdAt;
  final Map<String, dynamic> fields;
  static Map<String, dynamic> fromSettings(Settings settings) {
    final json = Map<String, dynamic>.from(settings.toJson())
      ..remove('schemaVersion')
      ..remove('salary')
      ..remove('start')
      ..remove('basis')
      ..remove('refreshMs')
      ..remove('digits');
    json['weekdays'] = (settings.weekdays.toList()..sort());
    json['overrides'] = {
      for (final key in settings.overrides.keys.toList()..sort())
        key: settings.overrides[key],
    };
    return json;
  }

  Settings snapshot(
    DateTime employment, {
    String salary = '0',
    SalaryBasis basis = SalaryBasis.annual,
    int refresh = 1000,
    int digits = 4,
  }) => Settings.fromJson({
    'schemaVersion': 1,
    'salary': salary,
    'start': EarningsPolicy.dateKey(employment),
    'basis': basis.name,
    'refreshMs': refresh,
    'digits': digits,
    ...fields,
  });
  ScheduleRuleVersion toCore(DateTime employment) => ScheduleRuleVersion(
    id: id,
    effectiveFrom: from,
    template: snapshot(employment).toPolicy(),
  );
  Map<String, Object> toJson() => {
    'id': id,
    'effectiveFrom': EarningsPolicy.dateKey(from),
    'createdAt': createdAt.toIso8601String(),
    'fields': fields,
  };
  factory ScheduleRecord.fromJson(Map<String, dynamic> j) => ScheduleRecord(
    id: j['id'] as String,
    from: profileDate(j['effectiveFrom'] as String),
    createdAt: _utcCreated(j['createdAt']),
    fields: j['fields'] as Map<String, dynamic>,
  );
}

/// Immutable v2 data. A retained revision records explicit replacement of a
/// same-date rule; no hidden pruning or reconstruction of actual past salary.
class ProfileDocument {
  ProfileDocument({
    required this.employmentStart,
    required this.createdAt,
    required List<SalaryRecord> salaries,
    required List<ScheduleRecord> schedules,
    this.revision = 1,
    this.nextId = 2,
    this.refreshMs = 1000,
    this.digits = 4,
    List<Map<String, dynamic>> replaced = const [],
    DateTime? updatedAt,
  }) : salaries = List.unmodifiable(salaries),
       schedules = List.unmodifiable(schedules),
       updatedAt = updatedAt ?? createdAt,
       replaced = List.unmodifiable(replaced.map(_freezeMap)) {
    if (revision < 1 ||
        nextId < 2 ||
        replaced.length > 512 ||
        ![100, 1000].contains(refreshMs) ||
        ![2, 4, 6].contains(digits)) {
      throw const FormatException('Invalid profile metadata or capacity');
    }
    profileDate(EarningsPolicy.dateKey(employmentStart));
    if (employmentStart !=
            DateTime.utc(
              employmentStart.year,
              employmentStart.month,
              employmentStart.day,
            ) ||
        !createdAt.isUtc ||
        !this.updatedAt.isUtc ||
        salaries.any((v) => !v.createdAt.isUtc) ||
        schedules.any((v) => !v.createdAt.isUtc)) {
      throw const FormatException(
        'Profile dates and metadata must be normalized UTC',
      );
    }
    engine();
    for (final id in [
      ...salaries.map((v) => v.id),
      ...schedules.map((v) => v.id),
    ]) {
      final number = int.tryParse(id.split('-').last);
      if (number == null || number >= nextId) {
        throw const FormatException('Invalid next rule ID');
      }
    }
  }
  final DateTime employmentStart, createdAt, updatedAt;
  final int revision, nextId, refreshMs, digits;
  final List<SalaryRecord> salaries;
  final List<ScheduleRecord> schedules;
  final List<Map<String, dynamic>> replaced;
  factory ProfileDocument.initial(Settings settings, DateTime now) =>
      ProfileDocument(
        employmentStart: settings.start,
        createdAt: now.toUtc(),
        refreshMs: settings.refreshMs,
        digits: settings.digits,
        salaries: [
          SalaryRecord(
            id: 'salary-1',
            from: settings.start,
            createdAt: now.toUtc(),
            salary: settings.salary,
            basis: settings.basis,
          ),
        ],
        schedules: [
          ScheduleRecord(
            id: 'schedule-1',
            from: settings.start,
            createdAt: now.toUtc(),
            fields: ScheduleRecord.fromSettings(settings),
          ),
        ],
      );
  SalaryRecord salaryAt(DateTime date) => salaries.lastWhere(
    (v) => !v.from.isAfter(date),
    orElse: () => salaries.first,
  );
  ScheduleRecord scheduleAt(DateTime date) => schedules.lastWhere(
    (v) => !v.from.isAfter(date),
    orElse: () => schedules.first,
  );
  VersionedEarningsEngine engine() => VersionedEarningsEngine(
    initial: schedules.first
        .snapshot(
          employmentStart,
          salary: salaries.first.salary,
          basis: salaries.first.basis,
        )
        .toPolicy(),
    salaries: salaries.map((v) => v.toCore()).toList(),
    schedules: schedules.map((v) => v.toCore(employmentStart)).toList(),
  );
  Settings view(DateTime civil, {bool migrationPending = false}) {
    final salary = salaryAt(civil), schedule = scheduleAt(civil);
    final snapshot = schedule.snapshot(
      employmentStart,
      salary: salary.salary,
      basis: salary.basis,
      refresh: refreshMs,
      digits: digits,
    );
    return Settings(
      salary: snapshot.salary,
      start: employmentStart,
      mode: snapshot.mode,
      basis: snapshot.basis,
      weekdays: snapshot.weekdays,
      startMinute: snapshot.startMinute,
      endMinute: snapshot.endMinute,
      lunch: snapshot.lunch,
      refreshMs: refreshMs,
      digits: digits,
      overrides: snapshot.overrides,
      shiftAttribution: snapshot.shiftAttribution,
      intervals: snapshot.intervals,
      breaks: snapshot.breaks,
      policyOverrides: snapshot.policyOverrides,
      calendarVersion: snapshot.calendarVersion,
      document: this,
      viewDate: civil,
      migrationPending: migrationPending,
    );
  }

  ProfileDocument change(Settings input, DateTime now) {
    input.toPolicy();
    if (input.document != null && input.document!.revision != revision) {
      throw const FormatException('Stale profile revision');
    }
    final civil = now.toUtc().add(const Duration(hours: 8));
    final at =
        input.effectiveFrom ?? DateTime.utc(civil.year, civil.month, civil.day);
    profileDate(EarningsPolicy.dateKey(at));
    if (!at.isUtc || at != DateTime.utc(at.year, at.month, at.day)) {
      throw const FormatException('Effective date must be civil midnight');
    }
    if (at.isBefore(input.start)) {
      throw const FormatException('Effective date precedes employment');
    }
    final before = view(input.viewDate ?? civil), changedAt = now.toUtc();
    var id = nextId;
    final pay = [...salaries], work = [...schedules], archive = [...replaced];
    final newPay =
        input.salaryVersionRequested ||
        input.toPolicy().monthlyMinor != before.toPolicy().monthlyMinor ||
        input.basis != before.basis;
    final newWork =
        input.scheduleVersionRequested ||
        jsonEncode(ScheduleRecord.fromSettings(input)) !=
            jsonEncode(ScheduleRecord.fromSettings(before));
    if (newPay) {
      final index = pay.indexWhere((v) => v.from == at);
      if (index >= 0) {
        archive.add({
          'kind': 'salary',
          'replacedAt': changedAt.toIso8601String(),
          'previous': pay[index].toJson(),
        });
        pay.removeAt(index);
      }
      pay.add(
        SalaryRecord(
          id: 'salary-${id++}',
          from: at,
          createdAt: changedAt,
          salary: input.salary,
          basis: input.basis,
        ),
      );
      pay.sort((a, b) => a.from.compareTo(b.from));
    }
    if (newWork) {
      final index = work.indexWhere((v) => v.from == at);
      if (index >= 0) {
        archive.add({
          'kind': 'schedule',
          'replacedAt': changedAt.toIso8601String(),
          'previous': work[index].toJson(),
        });
        work.removeAt(index);
      }
      work.add(
        ScheduleRecord(
          id: 'schedule-${id++}',
          from: at,
          createdAt: changedAt,
          fields: ScheduleRecord.fromSettings(input),
        ),
      );
      work.sort((a, b) => a.from.compareTo(b.from));
    }
    // The initial rule is an explicit baseline assumption, not invented salary
    // history. Changing employment can extend it only after the UI preview.
    if (input.start.isBefore(pay.first.from)) {
      final first = pay.first;
      pay[0] = SalaryRecord(
        id: first.id,
        from: input.start,
        createdAt: first.createdAt,
        salary: first.salary,
        basis: first.basis,
      );
    }
    if (input.start.isBefore(work.first.from)) {
      final first = work.first;
      work[0] = ScheduleRecord(
        id: first.id,
        from: input.start,
        createdAt: first.createdAt,
        fields: first.fields,
      );
    }
    return ProfileDocument(
      employmentStart: input.start,
      createdAt: createdAt,
      salaries: pay,
      schedules: work,
      revision: revision + 1,
      nextId: id,
      refreshMs: input.refreshMs,
      digits: input.digits,
      replaced: archive,
      updatedAt: changedAt,
    );
  }

  Map<String, Object> toJson() => {
    'schemaVersion': 2,
    'employmentStart': EarningsPolicy.dateKey(employmentStart),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'revision': revision,
    'nextId': nextId,
    'display': {'refreshMs': refreshMs, 'digits': digits},
    'salaries': salaries.map((v) => v.toJson()).toList(),
    'schedules': schedules.map((v) => v.toJson()).toList(),
    'replaced': replaced,
  };
  factory ProfileDocument.fromJson(Map<String, dynamic> j) {
    if (j['schemaVersion'] != 2) {
      throw const FormatException('Unsupported profile document');
    }
    final display = j['display'] as Map<String, dynamic>;
    return ProfileDocument(
      employmentStart: profileDate(j['employmentStart'] as String),
      createdAt: _utcCreated(j['createdAt']),
      salaries: (j['salaries'] as List)
          .map((v) => SalaryRecord.fromJson(v as Map<String, dynamic>))
          .toList(),
      schedules: (j['schedules'] as List)
          .map((v) => ScheduleRecord.fromJson(v as Map<String, dynamic>))
          .toList(),
      revision: j['revision'] as int,
      nextId: j['nextId'] as int,
      refreshMs: display['refreshMs'] as int,
      digits: display['digits'] as int,
      replaced: (j['replaced'] as List).cast<Map<String, dynamic>>(),
      updatedAt: _utcCreated(j['updatedAt'] ?? j['createdAt']),
    );
  }
}

Object? _freezeJson(Object? value) => switch (value) {
  Map<String, dynamic>() => _freezeMap(value),
  List() => List<Object?>.unmodifiable(value.map(_freezeJson)),
  _ => value,
};
Map<String, dynamic> _freezeMap(Map<String, dynamic> value) =>
    Map<String, dynamic>.unmodifiable(
      value.map((key, item) => MapEntry(key, _freezeJson(item))),
    );
