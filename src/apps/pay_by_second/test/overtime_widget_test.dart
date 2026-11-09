import 'package:earnings_core/earnings_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_by_second/app/app.dart';
import 'package:pay_by_second/application/overtime.dart';
import 'package:pay_by_second/application/settings.dart';
import 'package:pay_by_second/features/overtime/presentation/overtime_pages.dart';
import 'package:pay_by_second/features/settings/presentation/configuration_fields.dart';
import 'app_test.dart' show TestRepository, TestClock, TestLanguages, tap;

void main() {
  testWidgets(
    'first overtime setup, persisted active session, one tap stop and recovery',
    (tester) async {
      final clock = TestClock();
      final salary = TestRepository()
        ..value = Settings(salary: '17400', start: DateTime.utc(2026));
      final repo = MemoryOvertimeRepository();
      Future<void> launch() async {
        await tester.pumpWidget(
          PayBySecondApp(
            repository: salary,
            clock: clock,
            overtimeRepository: repo,
          ),
        );
        await tester.pumpAndSettle();
      }

      await launch();
      await tap(tester, find.byKey(const Key('overtime-toggle')));
      expect(repo.value.active, isNull);
      await tap(tester, find.byKey(const Key('overtime-save')));
      expect(repo.value.active, isNotNull);
      expect(find.byKey(const Key('overtime-joke')), findsOneWidget);
      clock.time = clock.time.add(const Duration(hours: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('这波约亏 ¥100.0000，老板快乐 +1'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await launch();
      expect(repo.value.active!.elapsed(clock.time), const Duration(hours: 1));
      await tap(tester, find.byKey(const Key('overtime-toggle')));
      expect(repo.value.active, isNull);
      expect(repo.value.entries.length, 1);
      expect(repo.value.entries.single.policy.pay, OvertimePay.unpaid);
      await tap(tester, find.byKey(const Key('overtime-toggle')));
      expect(repo.value.active!.id, 2);
      expect(find.byKey(const Key('overtime-save')), findsNothing);
      expect(salary.writes, 0);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'active overtime uses one foreground timer and pauses under settings and in background',
    (tester) async {
      final clock = TestClock();
      final repo = MemoryOvertimeRepository()
        ..value = OvertimeBook(
          policy: OvertimePolicy(monthlyMinor: BigInt.from(1740000)),
        ).start(clock.time);
      final salary = TestRepository()
        ..value = Settings(salary: '17400', start: DateTime.utc(2026));
      await tester.pumpWidget(
        PayBySecondApp(
          repository: salary,
          clock: clock,
          overtimeRepository: repo,
        ),
      );
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('overtime-details')));
      await tap(tester, find.byKey(const Key('overtime-settings')));
      final before = clock.calls;
      await tester.pump(const Duration(seconds: 4));
      expect(clock.calls, before);
      await tap(tester, find.byType(BackButton));
      final resumed = clock.calls;
      await tester.pump(const Duration(seconds: 1));
      expect(clock.calls, resumed + 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      final paused = clock.calls;
      await tester.pump(const Duration(seconds: 3));
      expect(clock.calls, paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      expect(clock.calls, paused + 1);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'wheel cancel preserves typed date and accepted value normalizes it',
    (tester) async {
      final salary = TestRepository()
        ..value = Settings(salary: '10000', start: DateTime.utc(2026));
      await tester.pumpWidget(
        PayBySecondApp(repository: salary, clock: TestClock()),
      );
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const Key('open-settings')));
      await tap(tester, find.text('薪资信息'));
      await tester.enterText(
        find.byKey(const Key('start-date-input')),
        '20261109',
      );
      await tap(tester, find.byTooltip('滑动选择'));
      expect(find.byType(CupertinoDatePicker), findsOneWidget);
      await tap(tester, find.text('取消'));
      expect(find.text('20261109'), findsOneWidget);
      await tap(tester, find.byTooltip('滑动选择'));
      final picker = tester.widget<CupertinoDatePicker>(
        find.byType(CupertinoDatePicker),
      );
      picker.onDateTimeChanged(DateTime(2026, 11, 10));
      await tap(tester, find.text('确定'));
      expect(find.text('2026-11-10'), findsOneWidget);
      expect(salary.writes, 0);
      expect(
        ConfigurationDraft.parseTime('01'),
        ConfigurationDraft.parseTime('1'),
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'overtime setup and details fit all three languages on a narrow phone',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final lang in ['zh', 'en', 'ja']) {
        final salary = TestRepository()
          ..value = Settings(salary: '10000', start: DateTime.utc(2026));
        await tester.pumpWidget(
          PayBySecondApp(
            repository: salary,
            clock: TestClock(),
            languageRepository: TestLanguages()..value = lang,
          ),
        );
        await tester.pumpAndSettle();
        await tap(tester, find.byKey(const Key('overtime-toggle')));
        expect(find.byType(OvertimeSettingsPage), findsOneWidget);
        expect(tester.takeException(), isNull, reason: lang);
        await tap(tester, find.byKey(const Key('overtime-save')));
        await tap(tester, find.byKey(const Key('overtime-details')));
        expect(find.byType(OvertimeDetailsPage), findsOneWidget);
        expect(tester.takeException(), isNull, reason: lang);
        await tester.pumpWidget(const SizedBox());
      }
    },
  );
}
