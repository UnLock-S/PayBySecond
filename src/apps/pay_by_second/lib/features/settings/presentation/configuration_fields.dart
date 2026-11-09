import 'dart:convert';
import 'package:earnings_core/earnings_core.dart';
import 'package:flutter/material.dart';
import '../../../application/settings.dart';
import '../../../shared/presentation/design.dart';

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
  ConfigurationDraft(Settings? original, DateTime now) {
    final s = original;
    salary.text = s?.salary ?? '';
    date.text = EarningsPolicy.dateKey(
      s?.start ?? now.toUtc().add(const Duration(hours: 8)),
    );
    start.text = _time(s?.startMinute ?? 480);
    end.text = _time(s?.endMinute ?? 1020);
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
  }
  final salary = TextEditingController(),
      date = TextEditingController(),
      start = TextEditingController(),
      end = TextEditingController();
  late AccrualMode mode;
  late SalaryBasis basis;
  late Set<int> days;
  late bool lunch;
  late int refresh, digits;
  late Map<String, bool> overrides;
  static String _time(int m) =>
      '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
  static DateTime? parseDate(String text) {
    final d = DateTime.tryParse(text.trim());
    if (d == null ||
        d.year < 1970 ||
        d.year > 2100 ||
        EarningsPolicy.dateKey(d) != text.trim()) {
      return null;
    }
    return DateTime.utc(d.year, d.month, d.day);
  }

  static int? parseTime(String text) {
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(text.trim())) return null;
    final p = text.trim().split(':').map(int.parse).toList();
    if (p[0] > 23 || p[1] > 59) return null;
    return p[0] * 60 + p[1];
  }

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
  );
  void dispose() {
    for (final c in [salary, date, start, end]) {
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
            Text(l.currencyNote, style: const TextStyle(color: muted)),
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
            TextFormField(
              key: const Key('start-date-input'),
              controller: d.date,
              onChanged: (_) => changed(),
              decoration: InputDecoration(
                labelText: l.startDate,
                hintText: 'YYYY-MM-DD',
              ),
              validator: (v) => ConfigurationDraft.parseDate(v ?? '') == null
                  ? l.dateError
                  : null,
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
                d.start.text == d.end.text
            ? l.shiftError
            : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.workOnlyNote, style: const TextStyle(color: muted)),
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
                child: Text(l.noWorkdays, style: const TextStyle(color: muted)),
              ),
            const SizedBox(height: 28),
            TextFormField(
              key: const Key('shift-start-input'),
              controller: d.start,
              onChanged: (_) => changed(),
              decoration: InputDecoration(
                labelText: l.shiftStart,
                hintText: 'HH:mm',
              ),
              validator: timeError,
            ),
            const SizedBox(height: 24),
            TextFormField(
              key: const Key('shift-end-input'),
              controller: d.end,
              onChanged: (_) => changed(),
              decoration: InputDecoration(
                labelText: l.shiftEnd,
                hintText: 'HH:mm',
              ),
              validator: timeError,
            ),
            const SizedBox(height: 12),
            Text(
              l.overnightHelp,
              style: const TextStyle(color: muted, fontSize: 12),
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
          ],
        );
      case ConfigSection.calendar:
        final keys = d.overrides.keys.toList()..sort();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.calendarWarning, style: const TextStyle(color: muted)),
            const SizedBox(height: 12),
            Text(
              l.workOnlyNote,
              style: const TextStyle(color: muted, fontSize: 12),
            ),
            const SizedBox(height: 24),
            if (keys.isEmpty) ...[
              const Icon(
                Icons.event_available_outlined,
                color: accent,
                size: 36,
              ),
              const SizedBox(height: 16),
              _heading(l.noOverrides),
              Text(l.noOverridesHelp, style: const TextStyle(color: muted)),
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
                final date = await showDatePicker(
                  context: context,
                  initialDate: seed,
                  firstDate: DateTime(1970),
                  lastDate: DateTime(2100, 12, 31),
                );
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
            Text(l.refreshHelp, style: const TextStyle(color: muted)),
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

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
    ),
  );
}
