import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pay_by_second/l10n/generated/app_localizations.dart';

void main() {
  test(
    'all locales have complete messages and identical placeholder contracts',
    () {
      final locales = ['en', 'zh', 'ja'];
      final maps = {
        for (final code in locales)
          code:
              jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
                  as Map<String, dynamic>,
      };
      final keys = maps['en']!.keys.where((k) => !k.startsWith('@')).toSet();
      for (final code in locales) {
        final translated = maps[code]!;
        expect(translated.keys.where((k) => !k.startsWith('@')).toSet(), keys);
        for (final key in keys) {
          expect(translated[key], isA<String>());
          expect((translated[key] as String).trim(), isNotEmpty);
          Set<String> placeholders(String message) => RegExp(
            r'\{(\w+)\}',
          ).allMatches(message).map((m) => m[1]!).toSet();
          expect(
            placeholders(translated[key]),
            placeholders(maps['en']![key]),
            reason: '$code: $key',
          );
        }
      }
      expect(
        AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
        locales.toSet(),
      );
    },
  );
}
