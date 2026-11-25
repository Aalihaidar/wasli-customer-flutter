import 'package:flutter/widgets.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/bidi_isolate.dart';

const int _metresPerKilometre = 1000;
const int _metresPerTenthOfKilometre = 100;

/// The text the customer sees for a distance of [metres]: `120 m` below one kilometre, then kilometres with at most one
/// decimal (`1.2 km`, `3 km`); `120 م` and `1.2 كم` in Arabic.
///
/// Digits are Western in both languages. A negative distance counts as zero. In Arabic the result is wrapped in a
/// left-to-right isolate so the number and its unit keep their order inside right-to-left text.
String formatDistance(int metres, {required Locale locale}) {
  final arabic = AppLocales.directionOf(locale) == TextDirection.rtl;
  final value = metres < 0 ? 0 : metres;
  final String text;
  if (value < _metresPerKilometre) {
    text = '$value ${arabic ? 'م' : 'm'}';
  } else {
    // Round to the nearest tenth of a kilometre with integer arithmetic only.
    final tenths = (value + _metresPerTenthOfKilometre ~/ 2) ~/ _metresPerTenthOfKilometre;
    final whole = tenths ~/ 10;
    final decimal = tenths % 10;
    final number = decimal == 0 ? '$whole' : '$whole.$decimal';
    text = '$number ${arabic ? 'كم' : 'km'}';
  }
  return arabic ? isolateLeftToRight(text) : text;
}
