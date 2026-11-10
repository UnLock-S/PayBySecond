import 'package:flutter/material.dart';
import 'package:earnings_core/earnings_core.dart';
import '../../../application/settings.dart';
import '../../../shared/presentation/design.dart';
import '../../../shared/presentation/financial_privacy.dart';
import 'dashboard.dart';

class TracePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l = context.l,
        engine = settings.toEngine(),
        hidden = FinancialPrivacy.hidden(context);
    final civil = engine.civilTime(now),
        start = engine.periodStart(period, now);
    final parts = engine.traceBetweenCivil(start, civil);
    return Scaffold(
      appBar: AppBar(title: Text(l.traceTitle)),
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.traceHelp),
            const SizedBox(height: 16),
            Text(
              '${periodLabel(period, l)} · ${EarningsPolicy.dateKey(start)} → ${civil.toIso8601String()}',
            ),
            const SizedBox(height: 16),
            for (final part in parts)
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
                      Text(
                        hidden
                            ? '••••'
                            : 'CNY ${part.amount.format(settings.digits)}',
                      ),
                      if (!hidden)
                        SelectableText(
                          '${part.toJson()['exactAmountMinorRational']}',
                        ),
                      Text(
                        'calendar: ${settings.document?.scheduleAt(part.start).fields['calendarVersion'] ?? settings.calendarVersion ?? 'personal'}',
                      ),
                    ],
                  ),
                ),
              ),
            if (parts.isEmpty) Text(l.notStarted),
          ],
        ),
      ),
    );
  }
}
