import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/locale_store.dart';

void main() {
  group('MemoryLocaleStore', () {
    test('has no language until one is saved', () async {
      expect(await MemoryLocaleStore().read(), isNull);
    });

    test('can start with a language', () async {
      expect(await MemoryLocaleStore(AppLocales.arabic).read(), AppLocales.arabic);
    });

    test('returns the language that was saved last', () async {
      final store = MemoryLocaleStore();

      await store.write(AppLocales.arabic);
      await store.write(AppLocales.english);

      expect(await store.read(), AppLocales.english);
    });

    test('is a LocaleStore, so a platform store can replace it', () {
      expect(MemoryLocaleStore(), isA<LocaleStore>());
      expect(const Locale('ar'), AppLocales.arabic);
    });
  });
}
