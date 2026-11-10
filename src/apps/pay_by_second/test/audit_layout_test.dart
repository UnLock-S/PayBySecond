import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_by_second/app/app.dart';
import 'package:pay_by_second/application/settings.dart';
import 'app_test.dart' show TestClock, TestLanguages, TestRepository;

void main() {
  for (final language in ['zh', 'en', 'ja']) {
    for (final size in [
      const Size(320, 640),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(640, 320),
    ]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          'AUD-10 $language ${size.width}x${size.height} text $scale',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            final repo = TestRepository()
              ..value = Settings(salary: '12345.67', start: DateTime.utc(2026));
            await tester.pumpWidget(
              PayBySecondApp(
                repository: repo,
                clock: TestClock(),
                languageRepository: TestLanguages()..value = language,
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox());
          },
        );
      }
    }
  }
}
