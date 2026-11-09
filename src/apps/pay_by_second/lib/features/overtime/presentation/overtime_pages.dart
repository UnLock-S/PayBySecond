import 'dart:async';
import 'package:earnings_core/earnings_core.dart';
import 'package:flutter/material.dart';
import '../../../application/income_session.dart';
import '../../../application/overtime.dart';
import '../../../application/date_time_input.dart';
import '../../../shared/presentation/design.dart';
import '../../../shared/presentation/date_time_field.dart';

String overtimeDayLabel(OvertimeDay day, AppLocalizations l) => switch (day) {
  OvertimeDay.weekday => l.otWeekday,
  OvertimeDay.rest => l.otRest,
  OvertimeDay.holiday => l.otHoliday,
};
String overtimePayLabel(OvertimePay pay, AppLocalizations l) => switch (pay) {
  OvertimePay.unpaid => l.otUnpaid,
  OvertimePay.statutory => l.otStatutory,
  OvertimePay.single => l.otSingle,
  OvertimePay.custom => l.otCustom,
};
String durationText(Duration duration) =>
    '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
String instantText(DateTime instant) {
  final date = instant.toUtc().add(const Duration(hours: 8));
  return '${EarningsPolicy.dateKey(date)} ${formatMinute(date.hour * 60 + date.minute)}';
}

class OvertimeCard extends StatelessWidget {
  const OvertimeCard({
    super.key,
    required this.controller,
    required this.now,
    required this.onToggle,
    required this.onDetails,
    this.hidden = false,
  });
  final OvertimeController controller;
  final DateTime now;
  final VoidCallback onToggle, onDetails;
  final bool hidden;
  @override
  Widget build(BuildContext context) {
    final l = context.l, c = controller;
    if (c.loading) return const LinearProgressIndicator();
    if (c.failed) {
      return Surface(
        child: Column(
          children: [
            Text(l.otLoadError),
            TextButton(onPressed: c.load, child: Text(l.retry)),
          ],
        ),
      );
    }
    final active = c.book.active;
    final elapsed = active?.elapsed(now) ?? Duration.zero;
    final total = c.closedDuration + elapsed;
    String money(Money value) =>
        hidden ? '••••' : '¥${grouped(value.format(4))}';
    return Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.more_time, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.otTitle,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                key: const Key('overtime-details'),
                onPressed: onDetails,
                tooltip: l.otDetails,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Text(
            active == null ? l.otIdle : l.otRunning,
            style: const TextStyle(color: muted),
          ),
          if ((active?.policy ?? c.book.policy) case final policy?)
            Text(
              '${overtimeDayLabel(policy.day, l)} · ${overtimePayLabel(policy.pay, l)}',
              style: const TextStyle(fontSize: 12, color: muted),
            ),
          const SizedBox(height: 12),
          Text(
            active == null
                ? '${l.otTotalTime}  ${durationText(total)}'
                : '${l.otThisTime}  ${durationText(elapsed)}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '${l.otExpected}: ${money(c.closedExpected + (active?.policy.expected(elapsed) ?? Money.zero))}',
          ),
          Text(
            '${l.otLegalReference}: ${money(c.closedStatutory + (active?.policy.statutory(elapsed) ?? Money.zero))}',
            style: const TextStyle(color: muted),
          ),
          if (active?.policy.pay == OvertimePay.unpaid) ...[
            const SizedBox(height: 12),
            Text(
              l.otJoke(money(active!.policy.unpaidValue(elapsed))),
              key: const Key('overtime-joke'),
              style: const TextStyle(color: Color(0xFF9C542D)),
            ),
            Text(
              l.otJokeHelp,
              style: const TextStyle(fontSize: 12, color: muted),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const Key('overtime-toggle'),
            onPressed: c.busy ? null : onToggle,
            icon: Icon(active == null ? Icons.play_arrow : Icons.stop),
            label: Text(
              c.busy
                  ? l.saving
                  : active == null
                  ? l.otStart
                  : l.otStop,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.otIndependent,
            style: const TextStyle(fontSize: 12, color: muted),
          ),
        ],
      ),
    );
  }
}

class OvertimeSettingsPage extends StatefulWidget {
  const OvertimeSettingsPage({
    super.key,
    required this.controller,
    required this.monthlyMinor,
    this.startAt,
  });
  final OvertimeController controller;
  final BigInt monthlyMinor;
  final DateTime Function()? startAt;
  @override
  State<OvertimeSettingsPage> createState() => _OvertimeSettingsPageState();
}

class _OvertimeSettingsPageState extends State<OvertimeSettingsPage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _base, _factor;
  late OvertimePay _pay;
  late OvertimeDay _day;
  late bool _leave;
  bool _saving = false, _failed = false;
  @override
  void initState() {
    super.initState();
    final p = widget.controller.book.policy;
    _base = TextEditingController(
      text: Money(
        p?.monthlyMinor ?? widget.monthlyMinor,
        BigInt.from(100),
      ).format(2),
    );
    _factor = TextEditingController(
      text: Money(
        BigInt.from(p?.multiplier ?? 150),
        BigInt.from(100),
      ).format(2),
    );
    _pay = p?.pay ?? OvertimePay.unpaid;
    _day = p?.day ?? OvertimeDay.weekday;
    _leave = p?.compensatoryLeave ?? false;
  }

  int? _hundredths(String text) {
    if (!RegExp(r'^\d{1,10}(\.\d{1,2})?$').hasMatch(text.trim())) return null;
    final p = text.trim().split('.');
    return int.parse(p[0]) * 100 +
        int.parse(p.length == 1 ? '0' : p[1].padRight(2, '0'));
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      final policy = OvertimePolicy(
        monthlyMinor: BigInt.from(_hundredths(_base.text)!),
        pay: _pay,
        day: _day,
        compensatoryLeave: _leave,
        multiplier: _pay == OvertimePay.custom
            ? _hundredths(_factor.text)!
            : 150,
      );
      await widget.controller.change((book) {
        final next = book.configure(policy);
        return widget.startAt == null ? next : next.start(widget.startAt!());
      });
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _failed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _base.dispose();
    _factor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(title: Text(l.otSettings)),
        body: PageBody(
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.otSettingsHelp, style: const TextStyle(color: muted)),
                const SizedBox(height: 24),
                DropdownButtonFormField<OvertimePay>(
                  key: const Key('overtime-pay'),
                  initialValue: _pay,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l.otPayMode),
                  items: [
                    for (final pay in OvertimePay.values)
                      DropdownMenuItem(
                        value: pay,
                        child: Text(overtimePayLabel(pay, l)),
                      ),
                  ],
                  onChanged: _saving ? null : (v) => setState(() => _pay = v!),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<OvertimeDay>(
                  key: const Key('overtime-day'),
                  initialValue: _day,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l.otDayType),
                  items: [
                    for (final day in OvertimeDay.values)
                      DropdownMenuItem(
                        value: day,
                        child: Text(overtimeDayLabel(day, l)),
                      ),
                  ],
                  onChanged: _saving ? null : (v) => setState(() => _day = v!),
                ),
                if (_day == OvertimeDay.rest)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.otCompLeave),
                    subtitle: Text(l.otCompHelp),
                    value: _leave,
                    onChanged: _saving
                        ? null
                        : (v) => setState(() => _leave = v),
                  ),
                const SizedBox(height: 20),
                TextFormField(
                  key: const Key('overtime-base'),
                  controller: _base,
                  enabled: !_saving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l.otBase,
                    prefixText: 'CNY  ',
                  ),
                  validator: (v) =>
                      _hundredths(v ?? '') == null ? l.salaryError : null,
                ),
                if (_pay == OvertimePay.custom) ...[
                  const SizedBox(height: 20),
                  TextFormField(
                    key: const Key('overtime-multiplier'),
                    controller: _factor,
                    enabled: !_saving,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(labelText: l.otMultiplier),
                    validator: (v) {
                      final factor = _hundredths(v ?? '');
                      return factor == null || factor < 1 || factor > 10000
                          ? l.otMultiplierError
                          : null;
                    },
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  l.otLegalHelp,
                  style: const TextStyle(color: muted, fontSize: 13),
                ),
                const SizedBox(height: 24),
                if (_failed)
                  Text(
                    l.otSaveError,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                FilledButton(
                  key: const Key('overtime-save'),
                  onPressed: _saving ? null : _save,
                  child: Text(
                    _saving
                        ? l.saving
                        : widget.startAt == null
                        ? l.otSaveDefaults
                        : l.otSaveStart,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OvertimeDetailsPage extends StatefulWidget {
  const OvertimeDetailsPage({
    super.key,
    required this.controller,
    required this.clock,
    required this.monthlyMinor,
  });
  final OvertimeController controller;
  final Clock clock;
  final BigInt monthlyMinor;
  @override
  State<OvertimeDetailsPage> createState() => _OvertimeDetailsPageState();
}

class _OvertimeDetailsPageState extends State<OvertimeDetailsPage>
    with WidgetsBindingObserver {
  Timer? _timer;
  late DateTime _now;
  bool _away = false;
  int _limit = 20;
  bool get _visible =>
      !_away &&
      (WidgetsBinding.instance.lifecycleState == null ||
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_refresh);
    _now = widget.clock.now();
    _schedule();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() => _now = widget.clock.now());
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    if (_visible && widget.controller.book.active != null) {
      _timer = Timer(const Duration(seconds: 1), _refresh);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_visible) {
      _refresh();
    } else {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.controller.removeListener(_refresh);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _configure() async {
    _away = true;
    _schedule();
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => OvertimeSettingsPage(
          controller: widget.controller,
          monthlyMinor: widget.monthlyMinor,
        ),
      ),
    );
    if (mounted) {
      _away = false;
      _refresh();
    }
  }

  Future<void> _change(OvertimeBook Function(OvertimeBook) update) async {
    try {
      await widget.controller.change(update);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l.otSaveError)));
      }
    }
  }

  Future<void> _edit(OvertimeEntry entry) async {
    _away = true;
    _schedule();
    final end = await Navigator.push<DateTime>(
      context,
      MaterialPageRoute(
        builder: (_) => _CorrectEndPage(entry: entry, now: widget.clock.now()),
      ),
    );
    if (!mounted) return;
    _away = false;
    if (end != null) await _change((book) => book.replace(entry.stop(end)));
    _refresh();
  }

  Future<void> _remove(OvertimeEntry entry) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l.otDeleteTitle),
        content: Text(context.l.otDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l.remove),
          ),
        ],
      ),
    );
    if (yes == true) await _change((book) => book.remove(entry.id));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l, c = widget.controller;
    final active = c.book.active;
    final elapsed = active?.elapsed(_now) ?? Duration.zero;
    final entries = c.book.entries.reversed.take(_limit);
    return Scaffold(
      appBar: AppBar(title: Text(l.otDetails)),
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l.otTotalTime}: ${durationText(c.closedDuration + elapsed)}',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              '${l.otExpected}: ¥${(c.closedExpected + (active?.policy.expected(elapsed) ?? Money.zero)).format(4)}',
            ),
            Text(
              '${l.otLegalReference}: ¥${(c.closedStatutory + (active?.policy.statutory(elapsed) ?? Money.zero)).format(4)}',
            ),
            Text(
              '${l.otUnpaidValue}: ¥${(c.closedUnpaid + (active?.policy.unpaidValue(elapsed) ?? Money.zero)).format(4)}',
            ),
            Text(
              l.otJokeHelp,
              style: const TextStyle(color: muted, fontSize: 12),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              key: const Key('overtime-settings'),
              onPressed: c.busy ? null : _configure,
              icon: const Icon(Icons.tune),
              label: Text(l.otSettings),
            ),
            if (c.book.policy != null)
              Text(
                '${overtimePayLabel(c.book.policy!.pay, l)} · ${overtimeDayLabel(c.book.policy!.day, l)}',
              ),
            const SizedBox(height: 20),
            Text(
              l.otLegalHelp,
              style: const TextStyle(color: muted, fontSize: 13),
            ),
            const Divider(height: 40),
            Text(
              l.otHistory,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              l.otHistoryHelp,
              style: const TextStyle(color: muted, fontSize: 12),
            ),
            if (active != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${l.otRunning} · ${durationText(elapsed)}'),
                subtitle: Text(
                  '${instantText(active.start)} → …\n${overtimeDayLabel(active.policy.day, l)} · ${overtimePayLabel(active.policy.pay, l)}',
                ),
              ),
            if (c.book.entries.isEmpty && active == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(l.otEmpty),
              ),
            for (final e in entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Surface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${instantText(e.start)} → ${instantText(e.end!)}'),
                      Text(
                        '${durationText(e.elapsed(e.end!))} · ${overtimeDayLabel(e.policy.day, l)} · ${overtimePayLabel(e.policy.pay, l)}',
                      ),
                      Text(
                        '${l.otExpected}: ¥${e.policy.expected(e.elapsed(e.end!)).format(4)}',
                      ),
                      Text(
                        '${l.otLegalReference}: ¥${e.policy.statutory(e.elapsed(e.end!)).format(4)}',
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton(
                            onPressed: c.busy ? null : () => _edit(e),
                            child: Text(l.otCorrectEnd),
                          ),
                          TextButton(
                            onPressed: c.busy ? null : () => _remove(e),
                            child: Text(l.remove),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (c.book.entries.length > _limit)
              TextButton(
                onPressed: () => setState(() => _limit += 20),
                child: Text(l.otMore),
              ),
          ],
        ),
      ),
    );
  }
}

class _CorrectEndPage extends StatefulWidget {
  const _CorrectEndPage({required this.entry, required this.now});
  final OvertimeEntry entry;
  final DateTime now;
  @override
  State<_CorrectEndPage> createState() => _CorrectEndPageState();
}

class _CorrectEndPageState extends State<_CorrectEndPage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _date, _time;
  @override
  void initState() {
    super.initState();
    final end = widget.entry.end!.add(const Duration(hours: 8));
    _date = TextEditingController(text: EarningsPolicy.dateKey(end));
    _time = TextEditingController(
      text: formatMinute(end.hour * 60 + end.minute),
    );
  }

  DateTime? _value() {
    final date = parseFlexibleDate(_date.text),
        minute = parseFlexibleTime(_time.text);
    if (date == null || minute == null) return null;
    return date.add(Duration(minutes: minute - 480));
  }

  @override
  void dispose() {
    _date.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l.otCorrectEnd)),
    body: PageBody(
      child: Form(
        key: _form,
        child: Column(
          children: [
            Text(context.l.otCorrectionHelp),
            const SizedBox(height: 24),
            DateTimeField(
              controller: _date,
              label: context.l.otEndDate,
              onChanged: () {},
            ),
            const SizedBox(height: 24),
            DateTimeField(
              controller: _time,
              label: context.l.otEndTime,
              time: true,
              onChanged: () {},
              validator: (_) {
                final value = _value();
                return value == null ||
                        value.isBefore(widget.entry.start) ||
                        value.isAfter(widget.now)
                    ? context.l.otEndError
                    : null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                if (_form.currentState!.validate()) {
                  Navigator.pop(context, _value());
                }
              },
              child: Text(context.l.otSaveCorrection),
            ),
          ],
        ),
      ),
    ),
  );
}
