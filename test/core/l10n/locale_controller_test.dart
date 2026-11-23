import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/locale_controller.dart';

ProviderContainer _container(List<Locale> deviceLocales) {
  final container = ProviderContainer(overrides: [deviceLocalesProvider.overrideWithValue(deviceLocales)]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('the starting language', () {
    test('is the first supported language of the device', () {
      expect(_container(const [Locale('ar', 'AE')]).read(localeProvider), AppLocales.arabic);
      expect(_container(const [Locale('en', 'GB')]).read(localeProvider), AppLocales.english);
    });

    test('is English when the device has none of ours', () {
      expect(_container(const [Locale('fr')]).read(localeProvider), AppLocales.english);
    });
  });

  group('LocaleController.setLocale', () {
    test('switches the language and tells the listeners', () {
      final container = _container(const [Locale('en')]);
      final seen = <Locale>[];
      container.listen(localeProvider, (_, next) => seen.add(next));

      container.read(localeProvider.notifier).setLocale(AppLocales.arabic);

      expect(container.read(localeProvider), AppLocales.arabic);
      expect(seen, [AppLocales.arabic]);
    });

    test('keeps the state a supported locale: a regional Arabic becomes plain Arabic', () {
      final container = _container(const [Locale('en')]);

      container.read(localeProvider.notifier).setLocale(const Locale('ar', 'AE'));

      expect(container.read(localeProvider), AppLocales.arabic);
    });

    test('refuses a language the app does not have and keeps the current one', () {
      final container = _container(const [Locale('en')]);

      expect(() => container.read(localeProvider.notifier).setLocale(const Locale('fr')), throwsArgumentError);
      expect(container.read(localeProvider), AppLocales.english);
    });
  });
}
