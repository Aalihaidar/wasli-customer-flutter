import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/locale_store.dart';

/// Where the customer's language choice is kept. Replaced at start-up with the platform's store.
final localeStoreProvider = Provider<LocaleStore>((ref) => MemoryLocaleStore());

/// The language saved from an earlier visit, read once at start-up before the first frame; `null` when none.
final savedLocaleProvider = Provider<Locale?>((ref) => null);

/// The language the app shows: English until the customer chooses another one in the settings, then that choice.
final localeProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);

/// Holds the active [Locale], always one of [AppLocales.supported].
///
/// The app starts in English whatever language the device uses (owner decision, 2026-11-23): the customer changes it in
/// the settings, and the choice is remembered through [LocaleStore].
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final saved = ref.read(savedLocaleProvider);
    return (saved == null ? null : AppLocales.normalize(saved)) ?? AppLocales.fallback;
  }

  /// Switches the app to [locale]'s language and remembers the choice.
  ///
  /// Throws an [ArgumentError] when the app has no translation for it, because the language list only offers supported
  /// ones and anything else is a programming error. A store that fails to save is not an error for the customer: the
  /// language still changes, it is just not remembered next time.
  void setLocale(Locale locale) {
    final supported = AppLocales.normalize(locale);
    if (supported == null) {
      throw ArgumentError.value(locale, 'locale', 'is not a supported language');
    }
    state = supported;
    unawaited(_remember(supported));
  }

  Future<void> _remember(Locale locale) async {
    try {
      await ref.read(localeStoreProvider).write(locale);
    } on Object {
      // Not remembered; see [setLocale].
    }
  }
}
