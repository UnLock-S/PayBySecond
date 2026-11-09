import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_by_second/app/app.dart';
import 'package:pay_by_second/application/income_session.dart';
import 'package:pay_by_second/application/settings.dart';

class _Clock implements Clock {
  DateTime time = DateTime.utc(2026, 11, 9, 2);
  int calls = 0;
  @override
  DateTime now() {
    calls++;
    return time;
  }
}

class _Repository implements SettingsRepository {
  Settings? value;
  bool fail = false;
  @override
  Future<Settings?> load() async => value;
  @override
  Future<void> save(Settings settings) async {
    if (fail) throw StateError('unavailable');
    value = settings;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

void main() {
  testWidgets('license page pauses the covered income dashboard', (
    tester,
  ) async {
    final repository = _Repository()
      ..value = Settings(salary: '10000', start: DateTime.utc(2026));
    final clock = _Clock();
    await tester.pumpWidget(
      PayBySecondApp(repository: repository, clock: clock),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('开源许可'));
    await tester.tap(find.text('开源许可'));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
    final callsBefore = clock.calls;
    await tester.pump(const Duration(minutes: 5));
    expect(clock.calls, callsBefore);
    await tester.tap(find.byTooltip('返回'));
    await tester.pumpAndSettle();
    expect(clock.calls, greaterThan(callsBefore));
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('configuration and work controls fit a mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      PayBySecondApp(repository: _Repository(), clock: _Clock()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('设置我的薪资'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byType(SwitchListTile).first);
    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('onboarding saves and dashboard releases timers on disposal', (
    tester,
  ) async {
    final repository = _Repository();
    await tester.pumpWidget(
      PayBySecondApp(repository: repository, clock: _Clock()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('设置我的薪资'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始累计'));
    await tester.pumpAndSettle();
    expect(repository.value, isNotNull);
    expect(find.text('调整估算配置'), findsOneWidget);
    expect(find.text('本日已赚 · CNY'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
  testWidgets('failed save preserves input and dialog', (tester) async {
    final repository = _Repository()..fail = true;
    await tester.pumpWidget(
      PayBySecondApp(repository: repository, clock: _Clock()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('设置我的薪资'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始累计'));
    await tester.pumpAndSettle();
    expect(repository.value, isNull);
    expect(find.textContaining('保存失败'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('hiding application stops refresh until resumed', (tester) async {
    final repository = _Repository()
      ..value = Settings(salary: '10000', start: DateTime.utc(2026));
    final clock = _Clock();
    await tester.pumpWidget(
      PayBySecondApp(repository: repository, clock: clock),
    );
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    final callsBefore = clock.calls;
    clock.time = clock.time.add(const Duration(minutes: 10));
    await tester.pump(const Duration(minutes: 10));
    expect(clock.calls, callsBefore, reason: 'No background clock queries');
    expect(tester.takeException(), isNull);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(
      clock.calls,
      callsBefore + 1,
      reason: 'Recompute immediately on resume',
    );
    await tester.pumpWidget(const SizedBox());
  });
}
