import 'package:flutter/material.dart';
import 'package:earnings_core/earnings_core.dart';
import '../../../application/settings.dart';
import '../../../shared/presentation/design.dart';
import '../../../shared/presentation/financial_privacy.dart';
import 'dashboard.dart';

class TracePage extends StatefulWidget {
  const TracePage({
    super.key,
    required this.settings,
    required this.now,
    required this.period,
  });
  final Settings settings;
  final DateTime now;
  final Period period;
  @override
  State<TracePage> createState() => _TracePageState();
}

class _TracePageState extends State<TracePage> {
  int limit = 30;
  late final engine = widget.settings.toEngine();
  late final civil = engine.civilTime(widget.now);
  late final start = engine.periodStart(widget.period, widget.now);
  late final parts = engine.traceBetweenCivil(start, civil);
  @override
  Widget build(BuildContext context) {
    final l = context.l,
        hidden = FinancialPrivacy.hidden(context),
        settings = widget.settings;
    return Scaffold(
      appBar: AppBar(title: Text(l.traceTitle)),
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.traceHelp),
            const SizedBox(height: 16),
            Text(
              '${periodLabel(widget.period, l)} · ${EarningsPolicy.dateKey(start)} → ${civil.toIso8601String()}',
            ),
            const SizedBox(height: 16),
            for (final part in parts.take(limit))
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Surface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${part.salaryRuleId} / ${part.scheduleRuleId}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${part.start.toIso8601String()} → ${part.end.toIso8601String()}',
                      ),
                      Text(
                        'salary.budget.v1 · ${part.numeratorMs} / ${part.denominatorMs} ms',
                      ),
                      if (part.denominatorMs == 0) Text(l.noEligibleTime),
                      Text(
                        hidden
                            ? '••••'
                            : 'CNY ${part.amount.format(settings.digits)}',
                      ),
                      if (!hidden)
                        SelectableText(
                          '${part.toJson()['exactAmountMinorRational']}',
                        ),
                      Text('${l.policySource}: ${part.calendarVersion}'),
                      if (part.calendarSourceDigest != null)
                        SelectableText('SHA-256 ${part.calendarSourceDigest}'),
                      if (settings.document
                              ?.scheduleAt(part.start)
                              .fields['calendarSource']
                          case final Map source)
                        Text('${(source['source'] as Map)['url']}'),
                    ],
                  ),
                ),
              ),
            if (parts.length > limit)
              TextButton(
                onPressed: () => setState(() => limit += 30),
                child: Text(l.moreDetails),
              ),
            if (parts.isEmpty) Text(l.notStarted),
          ],
        ),
      ),
    );
  }
}
