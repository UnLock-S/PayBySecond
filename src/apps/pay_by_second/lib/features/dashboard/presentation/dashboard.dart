import 'dart:async';
import 'package:earnings_core/earnings_core.dart';
import 'package:flutter/material.dart';
import '../../../application/income_session.dart';
import '../../../application/settings.dart';
import '../../../shared/presentation/design.dart';

String periodLabel(Period period, AppLocalizations l) => switch (period) {
  Period.employment => l.employment,
  Period.year => l.year,
  Period.month => l.month,
  Period.week => l.week,
  Period.day => l.day,
  Period.hour => l.hour,
};

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
    required this.settings,
    required this.clock,
    required this.enabled,
    this.overtimeActive = false,
    this.overtimeBuilder,
  });
  final Settings settings;
  final Clock clock;
  final bool enabled;
  final bool overtimeActive;
  final Widget Function(DateTime, bool)? overtimeBuilder;
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  late IncomeSession _session;
  late final ValueNotifier<EarningsSnapshot> _snapshot;
  Timer? _timer;
  Period _period = Period.day;
  bool _hidden = false;
  bool get _active =>
      widget.enabled &&
      (WidgetsBinding.instance.lifecycleState == null ||
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = IncomeSession(widget.settings, widget.clock);
    _snapshot = ValueNotifier(_session.snapshot());
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = null;
    if (!_active) return;
    final snap = _snapshot.value;
    final waiting =
        snap.rate.numerator == BigInt.zero && !widget.overtimeActive;
    final ms = waiting
        ? 60000 - (snap.now.second * 1000 + snap.now.millisecond)
        : widget.settings.refreshMs;
    _timer = Timer(Duration(milliseconds: ms), () {
      if (!_active) return;
      _snapshot.value = _session.snapshot();
      _schedule();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_active) _snapshot.value = _session.snapshot();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant Dashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _session = IncomeSession(widget.settings, widget.clock);
      _snapshot.value = _session.snapshot();
    } else if (widget.enabled && !oldWidget.enabled) {
      _snapshot.value = _session.snapshot();
    }
    _schedule();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _snapshot.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF162F36),
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Period>(
                        key: const Key('period-selector'),
                        isExpanded: true,
                        value: _period,
                        dropdownColor: const Color(0xFF203F45),
                        iconEnabledColor: Colors.white70,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.copyWith(color: Colors.white),
                        items: [
                          for (final p in Period.values)
                            DropdownMenuItem(
                              value: p,
                              child: Text(periodLabel(p, l)),
                            ),
                        ],
                        onChanged: (v) => setState(() => _period = v!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Semantics(
                    key: const Key('amount-visibility'),
                    child: IconButton(
                      key: ValueKey(_hidden),
                      tooltip: _hidden ? l.showAmount : l.hideAmount,
                      onPressed: () => setState(() => _hidden = !_hidden),
                      icon: Icon(
                        _hidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${l.earned} · CNY',
                style: const TextStyle(color: Color(0xFFB7CECA), fontSize: 13),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<EarningsSnapshot>(
                valueListenable: _snapshot,
                builder: (context, snap, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 86,
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _hidden
                              ? '••••••'
                              : 'CN¥ ${grouped(snap.amounts[_period]!.format(widget.settings.digits))}',
                          key: const Key('main-amount'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 64,
                            height: 1.1,
                            fontWeight: FontWeight.w600,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Icon(
                            Icons.circle,
                            color: Color(0xFF9CE6C5),
                            size: 8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            snap.now.isBefore(widget.settings.start)
                                ? l.notStarted
                                : _session.engine.policy.monthlyMinor ==
                                      BigInt.zero
                                ? l.zeroSalary
                                : snap.rate.numerator > BigInt.zero
                                ? l.accruing
                                : l.resting,
                            style: const TextStyle(color: Color(0xFF9CE6C5)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFF375156)),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _rate(
                            l.perSecond,
                            _hidden ? '••••' : snap.rate.format(6),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _rate(
                            l.perMinute,
                            _hidden ? '••••' : snap.rate.scale(60).format(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l.updatedAt(
                        snap.now
                            .toIso8601String()
                            .substring(0, 19)
                            .replaceFirst('T', ' '),
                      ),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ValueListenableBuilder<EarningsSnapshot>(
          valueListenable: _snapshot,
          builder: (context, snap, _) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final p in [Period.month, Period.employment]) ...[
                if (p == Period.employment) const SizedBox(width: 14),
                Expanded(
                  child: Surface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          periodLabel(p, l),
                          style: const TextStyle(color: muted),
                        ),
                        const SizedBox(height: 14),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _hidden
                                ? '••••••'
                                : grouped(
                                    snap.amounts[p]!.format(
                                      widget.settings.digits,
                                    ),
                                  ),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.overtimeBuilder != null)
          ValueListenableBuilder<EarningsSnapshot>(
            valueListenable: _snapshot,
            builder: (_, snap, _) => widget.overtimeBuilder!(
              snap.now.subtract(const Duration(hours: 8)),
              _hidden,
            ),
          ),
      ],
    );
  }

  Widget _rate(String label, String amount) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      const SizedBox(height: 6),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ),
    ],
  );
}
