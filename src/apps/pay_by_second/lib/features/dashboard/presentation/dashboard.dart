import 'dart:async';

import 'package:earnings_core/earnings_core.dart';
import 'package:flutter/material.dart';

import '../../../application/income_session.dart';
import '../../../application/settings.dart';

const _labels = {
  Period.employment: '入职以来',
  Period.year: '本年',
  Period.month: '本月',
  Period.week: '本周',
  Period.day: '本日',
  Period.hour: '本小时',
};

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
    required this.settings,
    required this.clock,
    required this.enabled,
    required this.onEdit,
    required this.onClear,
  });
  final Settings settings;
  final Clock clock;
  final bool enabled;
  final VoidCallback onEdit, onClear;
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  late final IncomeSession _session;
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
        widget.settings.mode == AccrualMode.work &&
        snap.rate.numerator == BigInt.zero;
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
    if (widget.enabled && !oldWidget.enabled) {
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final p in Period.values)
            ChoiceChip(
              label: Text(_labels[p]!),
              selected: _period == p,
              onSelected: (_) => setState(() => _period = p),
            ),
        ],
      ),
      const SizedBox(height: 16),
      ValueListenableBuilder<EarningsSnapshot>(
        valueListenable: _snapshot,
        builder: (context, snap, child) {
          final working = snap.rate.numerator > BigInt.zero;
          final future = snap.now.isBefore(widget.settings.start);
          String amount(Period p) => _hidden
              ? '••••••'
              : snap.amounts[p]!.format(widget.settings.digits);
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF162F36),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_labels[_period]}已赚 · CNY',
                            style: const TextStyle(
                              color: Color(0xFFB4C9C7),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: _hidden ? '显示金额' : '隐藏金额',
                          onPressed: () => setState(() => _hidden = !_hidden),
                          icon: Icon(
                            _hidden
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 76,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '¥ ${amount(_period)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 58,
                            fontWeight: FontWeight.w600,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      children: [
                        Text(
                          future
                              ? '○ 尚未入职'
                              : working
                              ? '● 正在累计'
                              : '○ 休息时间，金额暂停',
                          style: const TextStyle(color: Color(0xFF9CE6C5)),
                        ),
                        Text(
                          '当前速率  ${_hidden ? '••••' : snap.rate.format(6)} 元/秒',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '当前速率  ${_hidden ? '••••' : snap.rate.scale(60).format(4)} 元/分钟',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '计算至 ${snap.now.toIso8601String().substring(0, 19).replaceFirst('T', ' ')} · UTC+08:00',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth > 700
                      ? (constraints.maxWidth - 32) / 3
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final p in [
                        Period.year,
                        Period.month,
                        Period.employment,
                      ])
                        SizedBox(
                          width: width,
                          child: Card(
                            elevation: 0,
                            color: Colors.white,
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _labels[p]!,
                                    style: const TextStyle(
                                      color: Color(0xFF687A7C),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '¥ ${amount(p)}',
                                      style: const TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.w600,
                                        fontFeatures: [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
      const SizedBox(height: 22),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          Chip(
            label: Text(
              widget.settings.basis == SalaryBasis.annual ? '按年均摊' : '按月均摊',
            ),
          ),
          Chip(
            label: Text(
              widget.settings.mode == AccrualMode.calendar ? '全天累计' : '仅工作时段',
            ),
          ),
          Chip(label: Text('${widget.settings.refreshMs}ms 刷新')),
        ],
      ),
      if (widget.settings.mode == AccrualMode.work)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            '日历口径：每周排班 + 手动日期例外；尚未加载官方节假日和调休。',
            style: TextStyle(color: Color(0xFF846331)),
          ),
        ),
      const SizedBox(height: 18),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          OutlinedButton.icon(
            onPressed: widget.onEdit,
            icon: const Icon(Icons.tune),
            label: const Text('调整估算配置'),
          ),
          TextButton(onPressed: widget.onClear, child: const Text('清空本机数据')),
        ],
      ),
    ],
  );
}
