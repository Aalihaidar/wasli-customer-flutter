import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/locale_store.dart';

/// Keeps the customer's language in the platform's preferences: the browser's local storage on the web, the app's
/// preferences on Android and iOS.
///
/// Only the language code (`en` or `ar`) is stored. The language is not a secret, so plain preferences are right here;
/// they are **never** used for tokens or any other sensitive value (`security-privacy.md`).
class SharedPreferencesLocaleStore implements LocaleStore {
  /// Creates a store over the given preferences.
  const new(this._preferences);

  /// The key the language code is stored under.
  static const String storageKey = 'app_language';

  final SharedPreferencesAsync _preferences;

  /// The saved language, or `null` when there is none, when the saved value is not a language the app supports, or when
  /// the storage cannot be read (a browser that blocks it, for example). In every case the app simply starts in English,
  /// so a storage problem never keeps the app from starting.
  @override
  Future<Locale?> read() async {
    try {
      final code = await _preferences.getString(storageKey);
      return code == null ? null : AppLocales.normalize(Locale(code));
    } on Object {
      return null;
    }
  }

  /// Saves [locale]'s language code. Completes with an error when the storage refuses the write; the caller decides
  /// whether that matters.
  @override
  Future<void> write(Locale locale) => _preferences.setString(storageKey, locale.languageCode);
}
