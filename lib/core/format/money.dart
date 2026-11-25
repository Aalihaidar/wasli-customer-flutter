import 'package:flutter/widgets.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/bidi_isolate.dart';

/// Minor units in one major unit: the contract counts money in fils, 100 to the dirham.
const int _minorPerMajor = 100;

/// The text the customer sees for a price: [minor] fils of [currency], for example `AED 12.50` in English and
/// `12.50 د.إ` in Arabic.
///
/// The amount is an integer count of minor units and is never turned into a floating-point number. Digits are Western,
/// thousands are grouped with a comma (`AED 1,234.50`) and a negative amount starts with a minus sign. A currency other
/// than AED shows its code before the amount in both languages. In Arabic the result is wrapped in a left-to-right
/// isolate so the number and its unit keep their order inside right-to-left text.
String formatMoney(int minor, {required String currency, required Locale locale}) {
  final amount = _amount(minor.abs());
  final sign = minor < 0 ? '-' : '';
  final arabic = AppLocales.directionOf(locale) == TextDirection.rtl;
  if (arabic && currency == 'AED') return isolateLeftToRight('$sign$amount د.إ');
  final text = '$sign$currency $amount';
  return arabic ? isolateLeftToRight(text) : text;
}

String _amount(int minor) {
  final whole = (minor ~/ _minorPerMajor).toString();
  final fraction = (minor % _minorPerMajor).toString().padLeft(2, '0');
  return '${_group(whole)}.$fraction';
}

String _group(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
