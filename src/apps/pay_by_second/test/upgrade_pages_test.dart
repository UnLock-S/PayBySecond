import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:earnings_core/earnings_core.dart';
import 'package:pay_by_second/application/key_value_store.dart';
import 'package:pay_by_second/application/settings.dart';
import 'package:pay_by_second/features/dashboard/presentation/trace_page.dart';
import 'package:pay_by_second/features/settings/presentation/history_page.dart';
import 'package:pay_by_second/features/settings/presentation/policy_page.dart';
import 'package:pay_by_second/features/settings/presentation/recovery_page.dart';
import 'package:pay_by_second/infrastructure/financial_backup.dart';
import 'package:pay_by_second/infrastructure/policy_repository.dart';
import 'package:pay_by_second/infrastructure/recoverable_settings_repository.dart';
import 'package:pay_by_second/shared/presentation/appearance.dart';
import 'package:pay_by_second/shared/presentation/design.dart';
import 'package:pay_by_second/shared/presentation/financial_privacy.dart';

void main() {
  final now = DateTime.utc(2026, 11, 10, 2);
  final document = ProfileDocument.initial(
    Settings(salary: '12345.67', start: DateTime.utc(2026)),
    now,
  );
  for (final locale in ['zh', 'en', 'ja']) {
    for (final size in [
      const Size(320, 640),
      const Size(360, 800),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1280, 800),
      const Size(640, 320),
    ]) {
      for (final scale in [1.0, 2.0]) {
        for (final brightness in Brightness.values) {
          testWidgets('upgrade pages $locale $size text $scale $brightness', (
            tester,
          ) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            final store = MemoryKeyValueStore(), privacy = ValueNotifier(true);
            final settings = document.view(now), appearance = Appearance(store);
            final pages = <Widget>[
              HistoryPage(document: document),
              TracePage(settings: settings, now: now, period: Period.month),
              PolicyPage(
                repository: PolicyRepository(store),
                loadBundled: () async => PolicyRepository(
                  store,
                ).decode(File('assets/policy/cn-2026.json').readAsStringSync()),
                getSettings: () => settings,
                onSave: (_) async {},
                now: now,
              ),
              RecoveryPage(
                repository: RecoverableSettingsRepository(store),
                backup: FinancialBackup(store),
                onReload: () async {},
              ),
              AppearancePage(appearance: appearance),
            ];
            for (var i = 0; i < pages.length; i++) {
              await tester.pumpWidget(
                MaterialApp(
                  key: ValueKey(i),
                  locale: Locale(locale),
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  theme: ThemeData(useMaterial3: true, brightness: brightness),
                  home: FinancialPrivacy(state: privacy, child: pages[i]),
                ),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull, reason: 'page $i');
              if (i < 2) {
                expect(
                  find.textContaining('12345.67'),
                  findsNothing,
                  reason: 'hidden financial detail',
                );
              }
              // Exercise the bottom of long pages as well as their first frame.
              await tester.drag(
                find.byType(SingleChildScrollView).first,
                const Offset(0, -900),
              );
              await tester.pumpAndSettle();
              expect(
                tester.takeException(),
                isNull,
                reason: 'scrolled page $i',
              );
            }
            await tester.pumpWidget(const SizedBox());
            privacy.dispose();
            appearance.dispose();
          });
        }
      }
    }
  }
}
