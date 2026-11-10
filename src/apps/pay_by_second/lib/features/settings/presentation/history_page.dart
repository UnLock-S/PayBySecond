import 'package:flutter/material.dart';
import 'package:earnings_core/earnings_core.dart';
import '../../../application/settings.dart';
import '../../../shared/presentation/design.dart';
import '../../../shared/presentation/financial_privacy.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, required this.document});
  final ProfileDocument document;
  @override
  Widget build(BuildContext context) {
    final l = context.l, hidden = FinancialPrivacy.hidden(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.historyTitle)),
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.historyHelp),
            const SizedBox(height: 24),
            Text(
              l.salarySection,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            for (final rule in document.salaries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${rule.id} · ${EarningsPolicy.dateKey(rule.from)}',
                ),
                subtitle: Text(
                  '${hidden ? '••••' : 'CNY ${rule.salary}'} · ${rule.basis == SalaryBasis.annual ? l.annual : l.monthly}',
                ),
              ),
            const Divider(),
            Text(
              l.scheduleSection,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            for (final rule in document.schedules)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${rule.id} · ${EarningsPolicy.dateKey(rule.from)}',
                ),
                subtitle: Text(
                  '${rule.createdAt.toIso8601String()} · ${rule.fields['shiftAttribution'] ?? 'calendarDate'}',
                ),
              ),
            const Divider(),
            Text('${l.moreDetails}: ${document.replaced.length}'),
            for (final rule in document.replaced)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${(rule['previous'] as Map)['id']}'),
                subtitle: Text('${rule['replacedAt']}'),
              ),
          ],
        ),
      ),
    );
  }
}
