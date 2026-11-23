import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/locale_controller.dart';
import 'package:wasli_customer/core/l10n/locale_store.dart';
import 'package:wasli_customer/core/storage/shared_preferences_locale_store.dart';

/// The preferences of a test: a map instead of the browser's storage, optionally failing on read or write.
class _FakePreferences extends Fake implements SharedPreferencesAsync {
  new({this.failOnRead = false, this.failOnWrite = false});

  final Map<String, String> values = {};
  final bool failOnRead;
  final bool failOnWrite;

  @override
  Future<String?> getString(String key) async {
    if (failOnRead) throw StateError('storage is blocked');
    return values[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    if (failOnWrite) throw StateError('storage is full');
    values[key] = value;
  }
}

void main() {
  group('SharedPreferencesLocaleStore', () {
    test('is a LocaleStore', () {
      expect(SharedPreferencesLocaleStore(_FakePreferences()), isA<LocaleStore>());
    });

    test('has no language until one is saved', () async {
      expect(await SharedPreferencesLocaleStore(_FakePreferences()).read(), isNull);
    });

    test('saves the language code under one key and reads it back', () async {
      final preferences = _FakePreferences();
      final store = SharedPreferencesLocaleStore(preferences);

      await store.write(AppLocales.arabic);

      expect(preferences.values, {SharedPreferencesLocaleStore.storageKey: 'ar'});
      expect(await store.read(), AppLocales.arabic);
    });

    test('keeps only the language of a regional locale', () async {
      final preferences = _FakePreferences();
      final store = SharedPreferencesLocaleStore(preferences);

      await store.write(const Locale('ar', 'AE'));

      expect(preferences.values[SharedPreferencesLocaleStore.storageKey], 'ar');
    });

    test('returns the language saved last', () async {
      final store = SharedPreferencesLocaleStore(_FakePreferences());

      await store.write(AppLocales.arabic);
      await store.write(AppLocales.english);

      expect(await store.read(), AppLocales.english);
    });

    test('ignores a saved value that is not a supported language', () async {
      for (final value in ['fr', '', 'xx', 'ARABIC', '{"a":1}']) {
        final preferences = _FakePreferences()..values[SharedPreferencesLocaleStore.storageKey] = value;

        expect(await SharedPreferencesLocaleStore(preferences).read(), isNull, reason: 'saved value "$value"');
      }
    });

    test('reads as nothing saved when the storage cannot be read, so the app still starts', () async {
      expect(await SharedPreferencesLocaleStore(_FakePreferences(failOnRead: true)).read(), isNull);
    });

    test('reports a write the storage refuses, so the caller can decide', () async {
      final store = SharedPreferencesLocaleStore(_FakePreferences(failOnWrite: true));

      await expectLater(store.write(AppLocales.arabic), throwsStateError);
    });
  });

  group('with the locale controller', () {
    test('the chosen language is the starting language of the next visit', () async {
      final preferences = _FakePreferences();

      // First visit: the customer chooses Arabic in the settings.
      final firstVisit = ProviderContainer(
        overrides: [localeStoreProvider.overrideWithValue(SharedPreferencesLocaleStore(preferences))],
      );
      addTearDown(firstVisit.dispose);
      expect(firstVisit.read(localeProvider), AppLocales.english);
      firstVisit.read(localeProvider.notifier).setLocale(AppLocales.arabic);
      await Future<void>.delayed(Duration.zero);

      // Second visit: `bootstrap` reads the saved language before the first frame.
      final saved = await SharedPreferencesLocaleStore(preferences).read();
      final secondVisit = ProviderContainer(overrides: [savedLocaleProvider.overrideWithValue(saved)]);
      addTearDown(secondVisit.dispose);

      expect(secondVisit.read(localeProvider), AppLocales.arabic);
    });

    test('a storage that cannot save does not stop the language from changing', () async {
      final container = ProviderContainer(
        overrides: [
          localeStoreProvider.overrideWithValue(SharedPreferencesLocaleStore(_FakePreferences(failOnWrite: true))),
        ],
      );
      addTearDown(container.dispose);

      container.read(localeProvider.notifier).setLocale(AppLocales.arabic);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(localeProvider), AppLocales.arabic);
    });
  });
}
