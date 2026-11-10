import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_by_second/app/app.dart';
import 'package:pay_by_second/application/income_session.dart';
import 'package:pay_by_second/application/language_repository.dart';
import 'package:pay_by_second/application/settings.dart';
import 'package:pay_by_second/features/settings/presentation/configuration_editor.dart';

class TestClock implements Clock {
  DateTime time = DateTime.utc(2026, 11, 9, 2);
  int calls = 0;
  @override
  DateTime now() {
    calls++;
    return time;
  }
}

class TestRepository implements SettingsRepository {
  Settings? value;
  bool fail = false;
  int writes = 0;
  @override
  Future<Settings?> load() async => value;
  @override
  Future<void> save(Settings settings) async {
    if (fail) throw StateError('unavailable');
    value = settings;
    writes++;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

class TestLanguages extends MemoryLanguageRepository {
  bool fail = false;
  @override
  Future<void> save(String language) async {
    if (fail) throw StateError('unavailable');
    await super.save(language);
  }
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> launch(
  WidgetTester tester,
  TestRepository repository, {
  TestClock? clock,
  TestLanguages? languages,
}) async {
  await tester.pumpWidget(
    PayBySecondApp(
      repository: repository,
      clock: clock ?? TestClock(),
      languageRepository: languages,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> configured(WidgetTester tester, TestRepository repo) async {
  await launch(tester, repo);
  await tap(tester, find.byKey(const Key('get-started')));
  await tester.enterText(find.byKey(const Key('salary-input')), '10000');
  await tap(tester, find.byKey(const Key('config-submit')));
  expect(find.text('均摊基准'), findsOneWidget);
  expect(find.byKey(const Key('salary-input')), findsNothing);
  await tap(tester, find.byKey(const Key('config-submit')));
  expect(find.text('确认设置'), findsOneWidget);
}

void main() {
  testWidgets('work-only onboarding includes schedule before review', (
    tester,
  ) async {
    final repo = TestRepository();
    await launch(tester, repo);
    await tap(tester, find.byKey(const Key('get-started')));
    await tester.enterText(find.byKey(const Key('salary-input')), '12000');
    await tap(tester, find.byKey(const Key('config-submit')));
    await tap(tester, find.text('仅工作时段'));
    await tap(tester, find.byKey(const Key('config-submit')));
    expect(find.byKey(const Key('shift-start-input')), findsOneWidget);
    expect(repo.value, isNull);
    await tap(tester, find.byKey(const Key('config-submit')));
    expect(find.text('确认设置'), findsOneWidget);
    await tap(tester, find.byKey(const Key('config-submit')));
    expect(repo.value!.mode.name, 'work');
    expect(repo.value!.lunch, isTrue);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('calendar exceptions use date picker and typed workday choices', (
    tester,
  ) async {
    final repo = TestRepository()
      ..value = Settings(salary: '10000', start: DateTime.utc(2026));
    await launch(tester, repo);
    await tap(tester, find.byKey(const Key('open-settings')));
    await tap(tester, find.text('休假与补班'));
    await tap(tester, find.text('添加日期'));
    await tap(tester, find.text('确定'));
    expect(find.text('2026-01-01'), findsOneWidget);
    await tap(tester, find.byTooltip('修改'));
    await tap(tester, find.text('上班'));
    await tap(tester, find.byKey(const Key('config-submit')));
    await tap(tester, find.text('确认变更'));
    expect(repo.value!.overrides, {'2026-01-01': true});
    expect(repo.value!.salary, '10000');
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('setup is staged and commits only at final confirmation', (
    tester,
  ) async {
    final repo = TestRepository();
    await configured(tester, repo);
    expect(repo.value, isNull);
    expect(repo.writes, 0);
    await tap(tester, find.byKey(const Key('config-submit')));
    expect(repo.value!.salary, '10000');
    expect(repo.writes, 1);
    expect(find.byKey(const Key('open-settings')), findsOneWidget);
    expect(find.text('清空薪资数据'), findsNothing);
    expect(find.byType(ChoiceChip), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('failed final save retains the full draft and review page', (
    tester,
  ) async {
    final repo = TestRepository()..fail = true;
    await configured(tester, repo);
    await tap(tester, find.byKey(const Key('config-submit')));
    expect(repo.value, isNull);
    expect(find.text('保存失败，输入已保留，请重试。'), findsOneWidget);
    expect(find.byType(ConfigurationEditor), findsOneWidget);
    repo.fail = false;
    await tap(tester, find.byKey(const Key('config-submit')));
    expect(repo.value!.salary, '10000');
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('category editing isolates fields and discard does not write', (
    tester,
  ) async {
    final repo = TestRepository()
      ..value = Settings(salary: '12345', start: DateTime.utc(2026));
    await launch(tester, repo);
    await tap(tester, find.byKey(const Key('open-settings')));
    await tap(tester, find.text('薪资信息'));
    expect(find.byKey(const Key('salary-input')), findsOneWidget);
    expect(find.byKey(const Key('shift-start-input')), findsNothing);
    await tester.enterText(find.byKey(const Key('salary-input')), '20000');
    await tap(tester, find.byType(BackButton));
    expect(find.text('放弃未保存修改？'), findsOneWidget);
    await tap(tester, find.text('继续编辑'));
    expect(find.byKey(const Key('salary-input')), findsOneWidget);
    await tap(tester, find.byType(BackButton));
    await tap(tester, find.text('放弃修改'));
    expect(repo.value!.salary, '12345');
    expect(repo.writes, 0);
    await tap(tester, find.text('显示偏好'));
    expect(find.byKey(const Key('salary-input')), findsNothing);
    expect(find.byKey(const Key('refresh-input')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'income-affecting edits require explicit recalculation confirmation',
    (tester) async {
      final repo = TestRepository()
        ..value = Settings(salary: '10000', start: DateTime.utc(2026));
      await launch(tester, repo);
      await tap(tester, find.byKey(const Key('open-settings')));
      await tap(tester, find.text('薪资信息'));
      await tester.enterText(find.byKey(const Key('salary-input')), '20000');
      await tap(tester, find.byKey(const Key('config-submit')));
      expect(repo.writes, 0);
      expect(find.text('确认规则变更'), findsOneWidget);
      await tap(tester, find.text('确认变更'));
      expect(repo.value!.salary, '20000');
      expect(repo.writes, 1);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'language switch persists without rewriting salary, failure is reversible',
    (tester) async {
      final repo = TestRepository()
        ..value = Settings(salary: '12345.67', start: DateTime.utc(2026));
      final languages = TestLanguages();
      final before = jsonEncode(repo.value!.toJson());
      await launch(tester, repo, languages: languages);
      await tap(tester, find.byKey(const Key('open-settings')));
      await tap(tester, find.text('语言'));
      await tap(tester, find.byKey(const Key('language-en')));
      expect(find.text('Every second adds up.'), findsOneWidget);
      await tap(tester, find.byKey(const Key('open-settings')));
      await tap(tester, find.text('Language'));
      expect(languages.value, 'en');
      languages.fail = true;
      await tap(tester, find.byKey(const Key('language-ja')));
      expect(
        find.text(
          'Could not save language. The current language is unchanged.',
        ),
        findsOneWidget,
      );
      expect(languages.value, 'en');
      languages.fail = false;
      await tap(tester, find.byKey(const Key('language-ja')));
      expect(find.text('毎秒、積み重なる収入。'), findsOneWidget);
      expect(languages.value, 'ja');
      expect(jsonEncode(repo.value!.toJson()), before);
      expect(repo.writes, 0);
      await tester.pumpWidget(const SizedBox());
      await launch(tester, repo, languages: languages);
      expect(find.text('毎秒、積み重なる収入。'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('all settings destinations and locales fit a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final titles = {
      'zh': ['薪资信息', '计算方式', '工作时间', '休假与补班', '显示偏好', '语言', '数据与说明'],
      'en': [
        'Salary',
        'Calculation',
        'Work schedule',
        'Days off & make-up work',
        'Display',
        'Language',
        'Data & information',
      ],
      'ja': ['給与情報', '計算方式', '勤務時間', '休日・振替出勤', '表示設定', '言語', '情報・データ'],
    };
    for (final lang in titles.keys) {
      final repo = TestRepository()
        ..value = Settings(salary: '10000', start: DateTime.utc(2026));
      final languages = TestLanguages()..value = lang;
      await launch(tester, repo, languages: languages);
      expect(tester.takeException(), isNull);
      await tap(tester, find.byKey(const Key('open-settings')));
      for (final title in titles[lang]!) {
        await tap(tester, find.text(title));
        expect(tester.takeException(), isNull, reason: '$lang: $title');
        await tap(tester, find.byType(BackButton));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    }
  });
  testWidgets('secondary routes and hidden application do not poll income', (
    tester,
  ) async {
    final repo = TestRepository()
      ..value = Settings(salary: '10000', start: DateTime.utc(2026));
    final clock = TestClock();
    await launch(tester, repo, clock: clock);
    await tap(tester, find.byKey(const Key('amount-visibility')));
    await tap(tester, find.byKey(const Key('open-settings')));
    final calls = clock.calls;
    await tester.pump(const Duration(minutes: 10));
    expect(clock.calls, calls);
    await tap(tester, find.byType(BackButton));
    expect(clock.calls, greaterThan(calls));
    expect(
      tester.widget<Text>(find.byKey(const Key('main-amount'))).data,
      '••••••',
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    final paused = clock.calls;
    clock.time = clock.time.add(const Duration(minutes: 10));
    await tester.pump(const Duration(minutes: 10));
    expect(clock.calls, paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(clock.calls, paused + 1);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'clear salary data is confined to data page and preserves language',
    (tester) async {
      final repo = TestRepository()
        ..value = Settings(salary: '10000', start: DateTime.utc(2026));
      final languages = TestLanguages()..value = 'en';
      await launch(tester, repo, languages: languages);
      expect(find.text('Clear salary data'), findsNothing);
      await tap(tester, find.byKey(const Key('open-settings')));
      await tap(tester, find.text('Data & information'));
      await tap(tester, find.text('Clear salary data'));
      await tap(tester, find.widgetWithText(FilledButton, 'Clear salary data'));
      expect(repo.value, isNull);
      expect(languages.value, 'en');
      expect(find.byKey(const Key('get-started')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
