import 'package:earnings_core/earnings_core.dart';

import 'settings.dart';

abstract interface class Clock {
  DateTime now();
}

class EarningsSnapshot {
  EarningsSnapshot(this.now, this.amounts, this.rate);
  final DateTime now;
  final Map<Period, Money> amounts;
  final Money rate;
}

/// The historical part is evaluated only on configuration/date changes.
class IncomeSession {
  IncomeSession(Settings settings, this.clock)
    : engine = EarningsEngine(settings.toPolicy());
  final EarningsEngine engine;
  final Clock clock;
  DateTime? _date;
  final _baseline = <Period, Money>{};

  EarningsSnapshot snapshot() {
    final now = clock.now();
    final civil = engine.civilTime(now);
    final date = DateTime.utc(civil.year, civil.month, civil.day);
    if (_date != date) {
      _date = date;
      final midnight = date.subtract(
        Duration(minutes: engine.policy.utcOffsetMinutes),
      );
      for (final period in Period.values.where((p) => p != Period.hour)) {
        _baseline[period] = engine.betweenCivil(
          engine.periodStart(period, midnight),
          date,
        );
      }
    }
    final today = engine.betweenCivil(date, civil);
    return EarningsSnapshot(civil, {
      for (final period in Period.values)
        period: period == Period.hour
            ? engine.earned(period, now)
            : _baseline[period]! + today,
    }, engine.ratePerSecond(now));
  }
}
