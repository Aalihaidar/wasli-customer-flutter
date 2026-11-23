import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';

void main() {
  group('AppLocales.supported', () {
    test('are English and Arabic, English first', () {
      expect(AppLocales.supported, [const Locale('en'), const Locale('ar')]);
    });

    test('the fallback is English', () {
      expect(AppLocales.fallback, AppLocales.english);
    });
  });

  group('AppLocales.normalize', () {
    test('drops the country and the script', () {
      expect(AppLocales.normalize(const Locale('ar', 'AE')), AppLocales.arabic);
      expect(AppLocales.normalize(const Locale('en', 'GB')), AppLocales.english);
      expect(AppLocales.normalize(const Locale.fromSubtags(languageCode: 'ar', scriptCode: 'Arab')), AppLocales.arabic);
    });

    test('is null for a language the app does not have', () {
      expect(AppLocales.normalize(const Locale('fr')), isNull);
      expect(AppLocales.isSupported(const Locale('fr')), isFalse);
      expect(AppLocales.isSupported(const Locale('ar', 'SA')), isTrue);
    });
  });

  group('AppLocales.resolve', () {
    test('takes the first supported language of the device list', () {
      expect(AppLocales.resolve(const [Locale('ar', 'AE'), Locale('en', 'US')]), AppLocales.arabic);
      expect(AppLocales.resolve(const [Locale('en', 'US'), Locale('ar', 'AE')]), AppLocales.english);
    });

    test('skips languages the app does not have', () {
      expect(AppLocales.resolve(const [Locale('fr', 'FR'), Locale('ar')]), AppLocales.arabic);
    });

    test('falls back to English when the device offers nothing supported or nothing at all', () {
      expect(AppLocales.resolve(const [Locale('fr'), Locale('de')]), AppLocales.english);
      expect(AppLocales.resolve(const []), AppLocales.english);
    });
  });

  group('AppLocales.directionOf', () {
    test('Arabic is right to left, with or without a country', () {
      expect(AppLocales.directionOf(AppLocales.arabic), TextDirection.rtl);
      expect(AppLocales.directionOf(const Locale('ar', 'AE')), TextDirection.rtl);
    });

    test('English is left to right', () {
      expect(AppLocales.directionOf(AppLocales.english), TextDirection.ltr);
    });
  });
}
