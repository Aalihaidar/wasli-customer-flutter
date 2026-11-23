import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/locale_controller.dart';
import 'package:wasli_customer/core/l10n/locale_store.dart';

/// A store whose save always fails, to show that a language change does not depend on it.
class _FailingStore implements LocaleStore {
  @override
  Future<Locale?> read() async => null;

  @override
  Future<void> write(Locale locale) async => throw StateError('the disk is full');
}

ProviderContainer _container({Locale? saved, LocaleStore? store}) {
  final container = ProviderContainer(
    overrides: [
      if (saved != null) savedLocaleProvider.overrideWithValue(saved),
      if (store != null) localeStoreProvider.overrideWithValue(store),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('the starting language', () {
    test('is English when nothing was saved', () {
      expect(_container().read(localeProvider), AppLocales.english);
    });

    test('is the language saved from an earlier visit', () {
      expect(_container(saved: AppLocales.arabic).read(localeProvider), AppLocales.arabic);
    });

    test('is a plain supported locale even when the saved one carries a country', () {
      expect(_container(saved: const Locale('ar', 'AE')).read(localeProvider), AppLocales.arabic);
    });

    test('is English when the saved language is no longer supported', () {
      expect(_container(saved: const Locale('fr')).read(localeProvider), AppLocales.english);
    });
  });

  group('LocaleController.setLocale', () {
    test('switches the language and tells the listeners', () {
      final container = _container();
      final seen = <Locale>[];
      container.listen(localeProvider, (_, next) => seen.add(next));

      container.read(localeProvider.notifier).setLocale(AppLocales.arabic);

      expect(container.read(localeProvider), AppLocales.arabic);
      expect(seen, [AppLocales.arabic]);
    });

    test('remembers the choice in the store', () async {
      final store = MemoryLocaleStore();
      final container = _container(store: store);

      container.read(localeProvider.notifier).setLocale(AppLocales.arabic);
      await Future<void>.delayed(Duration.zero);

      expect(await store.read(), AppLocales.arabic);
    });

    test('keeps the state a supported locale: a regional Arabic becomes plain Arabic', () async {
      final store = MemoryLocaleStore();
      final container = _container(store: store);

      container.read(localeProvider.notifier).setLocale(const Locale('ar', 'AE'));
      await Future<void>.delayed(Duration.zero);

      expect(container.read(localeProvider), AppLocales.arabic);
      expect(await store.read(), AppLocales.arabic);
    });

    test('refuses a language the app does not have, keeps the current one and saves nothing', () async {
      final store = MemoryLocaleStore();
      final container = _container(store: store);

      expect(() => container.read(localeProvider.notifier).setLocale(const Locale('fr')), throwsArgumentError);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(localeProvider), AppLocales.english);
      expect(await store.read(), isNull);
    });

    test('still changes the language when the store cannot save it', () async {
      final container = _container(store: _FailingStore());

      container.read(localeProvider.notifier).setLocale(AppLocales.arabic);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(localeProvider), AppLocales.arabic);
    });
  });
}
