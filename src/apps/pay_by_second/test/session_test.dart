import 'package:earnings_core/earnings_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_by_second/application/income_session.dart';
import 'package:pay_by_second/application/settings.dart';

class FakeClock implements Clock {
  FakeClock(this.time);
  DateTime time;
  @override
  DateTime now() => time;
}

void main() {
  test(
    'cached historical totals equal direct engine through date and time jumps',
    () {
      final settings = Settings(
        salary: '12345.67',
        start: DateTime.utc(2020, 6, 15),
      );
      final clock = FakeClock(DateTime.utc(2026, 11, 9, 3));
      final session = IncomeSession(settings, clock);
      for (final now in [
        DateTime.utc(2026, 11, 9, 3),
        DateTime.utc(2026, 11, 9, 3, 0, 1),
        DateTime.utc(2026, 11, 9, 16),
        DateTime.utc(2027),
        DateTime.utc(2025, 2, 1),
      ]) {
        clock.time = now;
        final snap = session.snapshot();
        for (final period in Period.values) {
          expect(
            snap.amounts[period]!.format(6),
            session.engine.earned(period, now).format(6),
            reason: '$period at $now',
          );
        }
      }
    },
  );
  test('settings JSON roundtrip retains exact salary and overrides', () {
    final original = Settings(
      salary: '9999999999.99',
      start: DateTime.utc(2026),
      overrides: {'2026-01-01': false},
    );
    final loaded = Settings.fromJson(original.toJson());
    expect(loaded.toPolicy().monthlyMinor, BigInt.parse('999999999999'));
    expect(loaded.overrides, original.overrides);
    expect(loaded.start.isUtc, isTrue);
    expect(loaded.start, DateTime.utc(2026));
    expect(() => loaded.weekdays.add(7), throwsUnsupportedError);
  });
  test('invalid stored schema and salary are rejected', () {
    expect(
      () => Settings.fromJson({'schemaVersion': 2}),
      throwsFormatException,
    );
    expect(
      () => Settings(salary: 'NaN', start: DateTime.utc(2026)).toPolicy(),
      throwsFormatException,
    );
  });
}
