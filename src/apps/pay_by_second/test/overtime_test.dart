import 'dart:convert';
import 'package:earnings_core/earnings_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_by_second/application/date_time_input.dart';
import 'package:pay_by_second/application/overtime.dart';

class FailingRepository extends MemoryOvertimeRepository {
  bool fail = false;
  @override
  Future<void> save(OvertimeBook book) async {
    if (fail) throw StateError('disk unavailable');
    await super.save(book);
  }
}

void main() {
  test(
    'dates support compact, separators and kanji, rejecting invalid or ambiguous dates',
    () {
      for (final text in [
        '20261109',
        '2026-11-9',
        '2026/11/09',
        '2026.11.9',
        '2026 11 9',
        '2026年11月9日',
      ]) {
        expect(
          parseFlexibleDate(text),
          DateTime.utc(2026, 11, 9),
          reason: text,
        );
      }
      expect(parseFlexibleDate('2024/02/29'), DateTime.utc(2024, 2, 29));
      for (final text in [
        '2026/2/30',
        '20260229',
        '11/9/2026',
        '2026119',
        '2101-1-1',
        '2026-0-1',
      ]) {
        expect(parseFlexibleDate(text), isNull, reason: text);
      }
    },
  );
  test(
    'time permits single digits and compact 24-hour time without guessing decimal hours',
    () {
      for (final text in ['1', '01', '1:0', '01:00', '100', '0100']) {
        expect(parseFlexibleTime(text), 60, reason: text);
      }
      for (final text in [
        '805',
        '0805',
        '8:5',
        '8：05',
        '8时5分',
        '8時5分',
        '8 5',
      ]) {
        expect(parseFlexibleTime(text), 485, reason: text);
      }
      for (final text in [
        '24',
        '24:00',
        '8:60',
        '1.5',
        '-1',
        '12345',
        '8:5:1',
      ]) {
        expect(parseFlexibleTime(text), isNull, reason: text);
      }
    },
  );
  test(
    'active session recovers, rules retain history, duplicate starts and overlaps rejected',
    () {
      final start = DateTime.utc(2026, 11, 9);
      final policy = OvertimePolicy(monthlyMinor: BigInt.from(1740000));
      final book = OvertimeBook(policy: policy).start(start);
      final recovered = OvertimeBook.fromJson(
        jsonDecode(jsonEncode(book.toJson())) as Map<String, dynamic>,
      );
      expect(
        recovered.active!.elapsed(start.add(const Duration(hours: 5))),
        const Duration(hours: 5),
      );
      expect(() => book.start(start), throwsStateError);
      final changed = book.configure(
        OvertimePolicy(monthlyMinor: BigInt.from(3480000)),
      );
      expect(changed.active!.policy.monthlyMinor, policy.monthlyMinor);
      final closed = changed.stop(start.add(const Duration(hours: 1)));
      expect(closed.entries.single.policy.monthlyMinor, policy.monthlyMinor);
      expect(
        () => closed.start(start.add(const Duration(minutes: 1))),
        throwsFormatException,
      );
      expect(closed.start(start.add(const Duration(hours: 1))).active!.id, 2);
      expect(closed.remove(1).entries, isEmpty);
    },
  );
  test(
    'failed persistence retains active session and next id; retry cannot double count',
    () async {
      final repo = FailingRepository();
      final c = OvertimeController(repo);
      await c.load();
      final start = DateTime.utc(2026);
      await c.change(
        (b) => b
            .configure(OvertimePolicy(monthlyMinor: BigInt.from(1740000)))
            .start(start),
      );
      repo.fail = true;
      await expectLater(
        c.change((b) => b.stop(start.add(const Duration(hours: 1)))),
        throwsStateError,
      );
      expect(c.book.active, isNotNull);
      expect(c.book.entries, isEmpty);
      expect(c.busy, isFalse);
      repo.fail = false;
      await c.change((b) => b.stop(start.add(const Duration(hours: 1))));
      expect(c.book.entries.length, 1);
      expect(c.closedUnpaid.format(2), '100.00');
      expect(c.closedExpected.format(2), '0.00');
      c.dispose();
    },
  );
}
