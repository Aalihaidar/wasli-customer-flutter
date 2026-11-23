import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';

/// The locales the device lists, in order of preference. A provider so that a test can replace them.
final deviceLocalesProvider = Provider<List<Locale>>((ref) => PlatformDispatcher.instance.locales);

/// The language the app shows. It starts as the device's first supported language (English when there is none) and
/// changes when the customer picks another one.
final localeProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);

/// Holds the active [Locale], always one of [AppLocales.supported].
///
/// The choice is not stored yet: the customer's language is saved with the account (`locale` of the profile) when the
/// account screens exist.
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() => AppLocales.resolve(ref.read(deviceLocalesProvider));

  /// Switches the app to [locale]'s language.
  ///
  /// Throws an [ArgumentError] when the app has no translation for it, because the language switch only offers
  /// supported ones and anything else is a programming error.
  void setLocale(Locale locale) {
    final supported = AppLocales.normalize(locale);
    if (supported == null) {
      throw ArgumentError.value(locale, 'locale', 'is not a supported language');
    }
    state = supported;
  }
}
