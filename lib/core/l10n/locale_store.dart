import 'package:flutter/widgets.dart';

/// Where the language the customer chose is kept between visits.
///
/// An interface, because the place depends on the platform: the browser's storage on the web, the app's preferences on
/// Android and iOS. The language is not a secret (tokens never go through here), so any plain store will do.
abstract interface class LocaleStore {
  /// The saved language, or `null` when none was saved.
  Future<Locale?> read();

  /// Saves [locale] as the customer's choice.
  Future<void> write(Locale locale);
}

/// A [LocaleStore] that keeps the choice in memory only, so it is gone when the app closes.
///
/// The default until a platform store is wired, and the store that tests use.
class MemoryLocaleStore implements LocaleStore {
  /// Creates a store, optionally holding a language already.
  new([this._locale]);

  Locale? _locale;

  @override
  Future<Locale?> read() async => _locale;

  @override
  Future<void> write(Locale locale) async => _locale = locale;
}
