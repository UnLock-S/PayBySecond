import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:earnings_core/earnings_core.dart';
import '../../../application/settings.dart';
import '../../../infrastructure/policy_repository.dart';
import '../../../shared/presentation/design.dart';
import '../../../shared/presentation/date_time_field.dart';
import '../../../application/date_time_input.dart';

String classificationLabel(HolidayClassification value, AppLocalizations l) =>
    switch (value) {
      HolidayClassification.statutoryHoliday => l.legalHoliday,
      HolidayClassification.restDay => l.legalRest,
      HolidayClassification.adjustedWorkday => l.legalAdjusted,
      HolidayClassification.ordinaryWorkday => l.legalOrdinary,
      HolidayClassification.personalLeave => l.legalPersonal,
      HolidayClassification.companyDayOff => l.legalCompany,
      HolidayClassification.unknown => l.policyUnknown,
    };

class PolicyPage extends StatefulWidget {
  const PolicyPage({
    super.key,
    required this.repository,
    required this.getSettings,
    required this.onSave,
    required this.now,
    this.loadBundled,
  });
  final PolicyRepository repository;
  final Settings Function() getSettings;
  final Future<void> Function(Settings) onSave;
  final DateTime now;
  final Future<CalendarDataset> Function()? loadBundled;
  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  CalendarDataset? dataset;
  bool busy = true, failed = false, reviewed = false;
  late DateTime selected = widget.now.toUtc().add(const Duration(hours: 8));
  late final effective = TextEditingController(
    text: EarningsPolicy.dateKey(selected),
  );
  final form = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _run(() async {
      dataset =
          await widget.repository.load() ??
          await (widget.loadBundled?.call() ??
              rootBundle
                  .loadString('assets/policy/cn-2026.json')
                  .then(widget.repository.decode));
    });
  }

  @override
  void dispose() {
    effective.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (mounted) {
      setState(() {
        busy = true;
        failed = false;
      });
    }
    try {
      await action();
    } catch (_) {
      if (mounted) failed = true;
    }
    if (mounted) {
      setState(() {
        busy = false;
        reviewed = false;
      });
    }
  }

  Future<bool> _confirm(String detail) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l.policyTitle),
          content: SingleChildScrollView(child: Text(detail)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l.confirmSave),
            ),
          ],
        ),
      ) ??
      false;
  @override
  Widget build(BuildContext context) {
    final l = context.l, data = dataset, settings = widget.getSettings();
    final month = DateTime.utc(selected.year, selected.month),
        count = DateTime.utc(
          selected.year,
          selected.month + 1,
        ).subtract(const Duration(days: 1)).day;
    final current = data?.year == selected.year
        ? data!.on(selected)
        : const CalendarDay(HolidayClassification.unknown, null);
    final key = EarningsPolicy.dateKey(selected);
    final ruleSettings = settings.document?.view(selected) ?? settings;
    final policy = ruleSettings.toPolicy();
    final working =
        policy.dateOverrides[key] ?? policy.weekdays.contains(selected.weekday);
    return PopScope(
      canPop: !busy,
      child: Scaffold(
        appBar: AppBar(title: Text(l.policyTitle)),
        body: PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.policyHelp),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(
                  '${selected.year}-${selected.month.toString().padLeft(2, '0')}',
                ),
                onPressed: busy
                    ? null
                    : () async {
                        final value = await pickFlexibleDate(context, selected);
                        if (value != null && mounted) {
                          setState(() => selected = value);
                        }
                      },
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
                  final cell = 48 + 16 * (scale - 1).clamp(0, 2);
                  final width = constraints.maxWidth
                      .clamp(7 * cell, double.infinity)
                      .toDouble();
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: width,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              for (final name in [
                                l.mon,
                                l.tue,
                                l.wed,
                                l.thu,
                                l.fri,
                                l.sat,
                                l.sun,
                              ])
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: month.weekday - 1 + count,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  mainAxisExtent: 64 + 32 * (scale - 1),
                                ),
                            itemBuilder: (context, index) {
                              final day = index - month.weekday + 2;
                              if (day < 1) return const SizedBox.shrink();
                              final date = DateTime.utc(
                                    month.year,
                                    month.month,
                                    day,
                                  ),
                                  item = data?.year == selected.year
                                      ? data!.on(
                                          DateTime.utc(
                                            month.year,
                                            month.month,
                                            day,
                                          ),
                                        )
                                      : null;
                              return Semantics(
                                label: EarningsPolicy.dateKey(date),
                                selected: day == selected.day,
                                child: InkWell(
                                  onTap: () => setState(() => selected = date),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: day == selected.day
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primaryContainer
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$day',
                                          maxLines: 1,
                                          softWrap: false,
                                        ),
                                        if (item?.working != null)
                                          Icon(
                                            item!.working!
                                                ? Icons.work_outline
                                                : Icons.pause_circle_outline,
                                            size: 14,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Text(
                '${l.workingDay}: ◇ · ${l.restDay}: ○',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(key, style: Theme.of(context).textTheme.titleLarge),
                    Text(classificationLabel(current.classification, l)),
                    Text(
                      '${l.personalOverride}: ${ruleSettings.overrides.containsKey(key) ? (ruleSettings.overrides[key]! ? l.workingDay : l.restDay) : '—'}',
                    ),
                    Text(
                      '${l.scheduleSection}: ${working ? l.workingDay : l.restDay}',
                    ),
                    Text(
                      '${l.historyTitle}: ${settings.document?.salaryAt(selected).id ?? '—'} / ${settings.document?.scheduleAt(selected).id ?? '—'}',
                    ),
                    if (data?.year != selected.year) Text(l.noPolicyYear),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (data != null)
                Surface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.policySource,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SelectableText(
                        '${data.version}\n${data.source.documentNumber}\n${data.source.url}',
                      ),
                      Text(
                        data.source.review == PolicyReview.pending
                            ? l.policyPending
                            : l.policyReviewed,
                      ),
                      Text(
                        '${data.source.region}\n${data.source.publishedAt.toIso8601String()}\n${data.source.effectiveFrom.toIso8601String()} → ${data.source.effectiveUntil.toIso8601String()}\n${data.source.checkedAt.toIso8601String()}',
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l.policyConfirm),
                        value: reviewed,
                        onChanged: busy
                            ? null
                            : (v) => setState(() => reviewed = v!),
                      ),
                      Form(
                        key: form,
                        child: DateTimeField(
                          controller: effective,
                          label: l.effectiveDate,
                          onChanged: () {},
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: busy || !reviewed
                            ? null
                            : () async {
                                if (!form.currentState!.validate()) return;
                                if (!await _confirm(
                                  '${l.recalculateBody}\n\n${data.version}\n${l.effectiveDate}: ${effective.text}',
                                )) {
                                  return;
                                }
                                await _run(() async {
                                  final s = widget.getSettings();
                                  await widget.onSave(
                                    s.copyWith(
                                      policyOverrides: data.workOverrides,
                                      calendarVersion: data.version,
                                      effectiveFrom: parseFlexibleDate(
                                        effective.text,
                                      ),
                                    ),
                                  );
                                });
                              },
                        child: Text(l.policyApply),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.cloud_download_outlined),
                    label: Text(l.policyUpdate),
                    onPressed: busy
                        ? null
                        : () async {
                            if (await _confirm(l.policyNetwork)) {
                              await _run(() async {
                                dataset = await widget.repository.update();
                              });
                            }
                          },
                  ),
                  OutlinedButton(
                    onPressed: busy
                        ? null
                        : () => _run(() async {
                            await widget.repository.rollback();
                            dataset = await widget.repository.load();
                          }),
                    child: Text(l.policyRollback),
                  ),
                ],
              ),
              if (busy) const LinearProgressIndicator(),
              if (failed)
                Text(
                  l.policyCacheFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
