import 'dart:convert';
import 'package:earnings_core/earnings_core.dart';
import 'package:flutter/material.dart';
import '../../../application/settings.dart';
import '../../../application/date_time_input.dart';
import '../../../shared/presentation/date_time_field.dart';
import '../../../shared/presentation/design.dart';

class _IntervalDialog extends StatefulWidget {
  const _IntervalDialog();
  @override
  State<_IntervalDialog> createState() => _IntervalDialogState();
}

class _IntervalDialogState extends State<_IntervalDialog> {
  final start = TextEditingController(text: '08:00'),
      end = TextEditingController(text: '09:00');
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    start.dispose();
    end.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l.addInterval),
    content: SingleChildScrollView(
      child: Form(
        key: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DateTimeField(
              controller: start,
              label: context.l.shiftStart,
              time: true,
              onChanged: () {},
            ),
            const SizedBox(height: 16),
            DateTimeField(
              controller: end,
              label: context.l.shiftEnd,
              time: true,
              onChanged: () {},
              validator: (v) =>
                  parseFlexibleTime(v ?? '') == null ||
                      parseFlexibleTime(v ?? '') ==
                          parseFlexibleTime(start.text)
                  ? context.l.shiftError
                  : null,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l.cancel),
      ),
      FilledButton(
        onPressed: () {
          if (form.currentState!.validate()) {
            Navigator.pop(
              context,
              WorkInterval(
                parseFlexibleTime(start.text)!,
                parseFlexibleTime(end.text)!,
              ),
            );
          }
        },
        child: Text(context.l.save),
      ),
    ],
  );
}

enum ConfigSection { salary, calculation, schedule, calendar, display }

String sectionTitle(ConfigSection section, AppLocalizations l) =>
    switch (section) {
      ConfigSection.salary => l.salarySection,
      ConfigSection.calculation => l.calculationSection,
      ConfigSection.schedule => l.scheduleSection,
      ConfigSection.calendar => l.calendarSection,
      ConfigSection.display => l.displaySection,
    };

class ConfigurationDraft {
  ConfigurationDraft(this.original, DateTime now) {
    final s = original;
    salary.text = s?.salary ?? '';
    date.text = EarningsPolicy.dateKey(
      s?.start ?? now.toUtc().add(const Duration(hours: 8)),
    );
    start.text = _time(
      s != null && s.intervals.isNotEmpty
          ? s.intervals.first.start
          : s?.startMinute ?? 480,
    );
    end.text = _time(
      s != null && s.intervals.isNotEmpty
          ? s.intervals.first.end
          : s?.endMinute ?? 1020,
    );
    mode = s?.mode ?? AccrualMode.calendar;
    basis = s?.basis ?? SalaryBasis.annual;
    days = {
      ...?s?.weekdays,
      if (s == null) ...[1, 2, 3, 4, 5],
    };
    lunch = s?.lunch ?? true;
    refresh = s?.refreshMs ?? 1000;
    digits = s?.digits ?? 4;
    overrides = {...?s?.overrides};
    attribution = s?.shiftAttribution ?? ShiftAttribution.calendarDate;
    intervals = [...?s?.intervals];
    breaks = [...?s?.breaks];
    effective.text = EarningsPolicy.dateKey(
      now.toUtc().add(const Duration(hours: 8)),
    );
  }
  final Settings? original;
  final salary = TextEditingController(),
      date = TextEditingController(),
      start = TextEditingController(),
      end = TextEditingController(),
      effective = TextEditingController();
  late AccrualMode mode;
  late SalaryBasis basis;
  late Set<int> days;
  late bool lunch;
  late int refresh, digits;
  late Map<String, bool> overrides;
  late ShiftAttribution attribution;
  late List<WorkInterval> intervals, breaks;
  static String _time(int m) =>
      '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
  static DateTime? parseDate(String text) => parseFlexibleDate(text);
  static int? parseTime(String text) => parseFlexibleTime(text);

  String get fingerprint => jsonEncode([
    salary.text,
    date.text,
    start.text,
    end.text,
    mode.name,
    basis.name,
    days.toList()..sort(),
    lunch,
    refresh,
    digits,
    attribution.name,
    effective.text,
    intervals.map((v) => v.toJson()).toList(),
    breaks.map((v) => v.toJson()).toList(),
    for (final key in overrides.keys.toList()..sort()) [key, overrides[key]],
  ]);
  Settings build() => Settings(
    salary: salary.text.trim(),
    start: parseDate(date.text)!,
    mode: mode,
    basis: basis,
    weekdays: days,
    startMinute: parseTime(start.text)!,
    endMinute: parseTime(end.text)!,
    lunch: lunch,
    refreshMs: refresh,
    digits: digits,
    overrides: overrides,
    shiftAttribution: attribution,
    intervals: intervals.isEmpty
        ? []
        : [
            WorkInterval(parseTime(start.text)!, parseTime(end.text)!),
            ...intervals.skip(1),
          ],
    breaks: breaks,
    document: original?.document,
    viewDate: original?.viewDate,
    effectiveFrom: original?.document == null
        ? null
        : parseDate(effective.text),
    policyOverrides: original?.policyOverrides ?? const {},
    calendarVersion: original?.calendarVersion,
  );
  void dispose() {
    for (final c in [salary, date, start, end, effective]) {
      c.dispose();
    }
  }
}

class ConfigurationFields extends StatelessWidget {
  const ConfigurationFields({
    super.key,
    required this.section,
    required this.draft,
    required this.changed,
  });
  final ConfigSection section;
  final ConfigurationDraft draft;
  final VoidCallback changed;
  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final d = draft;
    switch (section) {
      case ConfigSection.salary:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.currencyNote,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              key: const Key('salary-input'),
              controller: d.salary,
              onChanged: (_) => changed(),
              decoration: InputDecoration(
                labelText: l.salaryLabel,
                hintText: '10000.00',
                prefixText: 'CNY  ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) =>
                  RegExp(r'^\d{1,10}(\.\d{1,2})?$').hasMatch(v?.trim() ?? '')
                  ? null
                  : l.salaryError,
            ),
            const SizedBox(height: 24),
            DateTimeField(
              key: const Key('start-date-input'),
              controller: d.date,
              label: l.startDate,
              onChanged: changed,
            ),
          ],
        );
      case ConfigSection.calculation:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading(l.budgetBasis),
            RadioGroup<SalaryBasis>(
              groupValue: d.basis,
              onChanged: (value) {
                d.basis = value!;
                changed();
              },
              child: Column(
                children: [
                  RadioListTile(
                    value: SalaryBasis.annual,
                    title: Text(l.annual),
                    subtitle: Text(l.annualHelp),
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile(
                    value: SalaryBasis.monthly,
                    title: Text(l.monthly),
                    subtitle: Text(l.monthlyHelp),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const Divider(height: 40),
            _heading(l.paidTime),
            RadioGroup<AccrualMode>(
              groupValue: d.mode,
              onChanged: (value) {
                d.mode = value!;
                changed();
              },
              child: Column(
                children: [
                  RadioListTile(
                    value: AccrualMode.calendar,
                    title: Text(l.calendarMode),
                    subtitle: Text(l.calendarHelp),
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile(
                    value: AccrualMode.work,
                    title: Text(l.workMode),
                    subtitle: Text(l.workHelp),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        );
      case ConfigSection.schedule:
        final names = [l.mon, l.tue, l.wed, l.thu, l.fri, l.sat, l.sun];
        String? timeError(String? _) =>
            ConfigurationDraft.parseTime(d.start.text) == null ||
                ConfigurationDraft.parseTime(d.end.text) == null ||
                parseFlexibleTime(d.start.text) == parseFlexibleTime(d.end.text)
            ? l.shiftError
            : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.workOnlyNote,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _heading(l.weekdays),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 1; i <= 7; i++)
                  FilterChip(
                    label: Text(names[i - 1]),
                    selected: d.days.contains(i),
                    onSelected: (v) {
                      v ? d.days.add(i) : d.days.remove(i);
                      changed();
                    },
                  ),
              ],
            ),
            if (d.days.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  l.noWorkdays,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 28),
            DateTimeField(
              key: const Key('shift-start-input'),
              controller: d.start,
              label: l.shiftStart,
              time: true,
              onChanged: changed,
              validator: timeError,
            ),
            const SizedBox(height: 24),
            DateTimeField(
              key: const Key('shift-end-input'),
              controller: d.end,
              label: l.shiftEnd,
              time: true,
              onChanged: changed,
              validator: timeError,
            ),
            const SizedBox(height: 12),
            Text(
              l.overnightHelp,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l.lunch),
              subtitle: Text(l.lunchDetail),
              value: d.lunch,
              onChanged: (v) {
                d.lunch = v;
                changed();
              },
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<ShiftAttribution>(
              isExpanded: true,
              initialValue: d.attribution,
              decoration: InputDecoration(labelText: l.attribution),
              items: [
                DropdownMenuItem(
                  value: ShiftAttribution.calendarDate,
                  child: Text(l.calendarDate),
                ),
                DropdownMenuItem(
                  value: ShiftAttribution.shiftStartDate,
                  child: Text(l.shiftStartDate),
                ),
              ],
              onChanged: (v) {
                d.attribution = v!;
                changed();
              },
            ),
            const SizedBox(height: 12),
            Text(
              l.attributionHelp,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _intervals(context, l.workIntervals, d.intervals, work: true),
            const SizedBox(height: 24),
            _intervals(context, l.breakIntervals, d.breaks),
          ],
        );
      case ConfigSection.calendar:
        final keys = d.overrides.keys.toList()..sort();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.calendarWarning,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.workOnlyNote,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            if (keys.isEmpty) ...[
              Icon(Icons.event_available_outlined, color: accent, size: 36),
              const SizedBox(height: 16),
              _heading(l.noOverrides),
              Text(
                l.noOverridesHelp,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
            ],
            for (final key in keys)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(key),
                subtitle: Text(d.overrides[key]! ? l.workingDay : l.restDay),
                trailing: PopupMenuButton<String>(
                  tooltip: l.edit,
                  onSelected: (v) {
                    if (v == 'remove') {
                      d.overrides.remove(key);
                    } else {
                      d.overrides[key] = v == 'work';
                    }
                    changed();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'work', child: Text(l.workingDay)),
                    PopupMenuItem(value: 'rest', child: Text(l.restDay)),
                    PopupMenuItem(value: 'remove', child: Text(l.remove)),
                  ],
                ),
              ),
            OutlinedButton.icon(
              onPressed: () async {
                final seed =
                    ConfigurationDraft.parseDate(d.date.text) ??
                    DateTime.utc(2026);
                final date = await pickFlexibleDate(context, seed);
                if (date != null) {
                  d.overrides[EarningsPolicy.dateKey(date)] = false;
                  changed();
                }
              },
              icon: const Icon(Icons.add),
              label: Text(l.addDate),
            ),
          ],
        );
      case ConfigSection.display:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              key: const Key('refresh-input'),
              isExpanded: true,
              initialValue: d.refresh,
              decoration: InputDecoration(labelText: l.refresh),
              items: [
                DropdownMenuItem(value: 1000, child: Text(l.refreshNormal)),
                DropdownMenuItem(value: 100, child: Text(l.refreshFast)),
              ],
              onChanged: (v) {
                d.refresh = v!;
                changed();
              },
            ),
            const SizedBox(height: 12),
            Text(
              l.refreshHelp,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            DropdownButtonFormField<int>(
              isExpanded: true,
              initialValue: d.digits,
              decoration: InputDecoration(labelText: l.precision),
              items: [
                for (final n in [2, 4, 6])
                  DropdownMenuItem(value: n, child: Text(l.digitsLabel(n))),
              ],
              onChanged: (v) {
                d.digits = v!;
                changed();
              },
            ),
          ],
        );
    }
  }

  Widget _intervals(
    BuildContext context,
    String title,
    List<WorkInterval> values, {
    bool work = false,
  }) {
    final l = context.l;
    final visible = work ? values.skip(1).toList() : values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(title),
        for (final value in visible)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              '${ConfigurationDraft._time(value.start)}–${ConfigurationDraft._time(value.end)}',
            ),
            trailing: IconButton(
              tooltip: l.remove,
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                values.remove(value);
                changed();
              },
            ),
          ),
        OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: Text(l.addInterval),
          onPressed: values.length >= 16
              ? null
              : () async {
                  if (work &&
                      values.isEmpty &&
                      (ConfigurationDraft.parseTime(draft.start.text) == null ||
                          ConfigurationDraft.parseTime(draft.end.text) ==
                              null ||
                          ConfigurationDraft.parseTime(draft.start.text) ==
                              ConfigurationDraft.parseTime(draft.end.text))) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l.shiftError)));
                    return;
                  }
                  final result = await showDialog<WorkInterval>(
                    context: context,
                    builder: (_) => const _IntervalDialog(),
                  );
                  if (result == null) return;
                  if (work && values.isEmpty) {
                    values.add(
                      WorkInterval(
                        ConfigurationDraft.parseTime(draft.start.text)!,
                        ConfigurationDraft.parseTime(draft.end.text)!,
                      ),
                    );
                  }
                  values.add(result);
                  changed();
                },
        ),
      ],
    );
  }

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
    ),
  );
}
