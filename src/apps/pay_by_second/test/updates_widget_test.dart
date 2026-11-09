import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_by_second/app/app.dart';
import 'package:pay_by_second/application/app_updates.dart';
import 'package:pay_by_second/application/settings.dart';
import 'package:pay_by_second/infrastructure/update_platform_native.dart';
import 'app_test.dart' show TestClock, TestLanguages, TestRepository, tap;
import 'app_updates_test.dart'
    show FakeReleaseTransport, FakeUpdatePlatform, releaseJson;

void main() {
  testWidgets(
    'Android bridge reads installed metadata and launches the validated HTTPS release link',
    (tester) async {
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        AppUpdatePlatform.channel,
        (call) async {
          calls.add(call);
          return call.method == 'appInfo'
              ? {'version': '0.2.1', 'build': '2003', 'abi': 'arm64-v8a'}
              : true;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          AppUpdatePlatform.channel,
          null,
        ),
      );
      final platform = AppUpdatePlatform();
      expect((await platform.installed()).build, '2003');
      expect(
        await platform.open(
          Uri.parse('https://github.com/UnLock-S/PayBySecond/releases'),
        ),
        isTrue,
      );
      expect(calls.map((c) => c.method), ['appInfo', 'openRelease']);
    },
  );
  testWidgets(
    'new release banner opens update page, preserves profile and delegates download to browser',
    (tester) async {
      final repo = TestRepository()
        ..value = Settings(salary: '10000', start: DateTime.utc(2026));
      final platform = FakeUpdatePlatform(), prefs = MemoryUpdatePreferences();
      final updates = UpdateController(
        source: ReleaseSource('UnLock-S/PayBySecond'),
        transport: FakeReleaseTransport(),
        preferences: prefs,
        platform: platform,
      );
      await tester.pumpWidget(
        PayBySecondApp(repository: repo, clock: TestClock(), updates: updates),
      );
      await tester.pumpAndSettle();
      await tap(tester, find.text('发现新版 0.3.0'));
      expect(find.text('当前版本 0.2.1 (2003)'), findsOneWidget);
      await tap(tester, find.byKey(const Key('download-update')));
      expect(
        platform.opened.single.path,
        endsWith('PayBySecond-0.3.0-arm64-v8a-test.apk'),
      );
      await tap(tester, find.byKey(const Key('automatic-updates')));
      expect(prefs.value.automatic, isFalse);
      expect(repo.writes, 0);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'missing APK never enables download; all three language update pages fit 360px',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final lang in ['zh', 'en', 'ja']) {
        final transport = FakeReleaseTransport()
          ..response = ReleaseResponse(
            200,
            json: releaseJson(abis: ['x86_64']),
          );
        final controller = UpdateController(
          source: ReleaseSource('UnLock-S/PayBySecond'),
          transport: transport,
          preferences: MemoryUpdatePreferences(),
          platform: FakeUpdatePlatform(),
        );
        await tester.pumpWidget(
          PayBySecondApp(
            repository: TestRepository(),
            clock: TestClock(),
            languageRepository: TestLanguages()..value = lang,
            updates: controller,
          ),
        );
        await tester.pumpAndSettle();
        await tap(tester, find.byKey(const Key('open-updates')));
        expect(find.byKey(const Key('download-update')), findsNothing);
        expect(find.byKey(const Key('open-releases')), findsOneWidget);
        expect(tester.takeException(), isNull, reason: lang);
        await tester.pumpWidget(const SizedBox());
      }
    },
  );
}
