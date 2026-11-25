import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/format/money.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/bidi_isolate.dart';

void main() {
  const en = AppLocales.english;
  const ar = AppLocales.arabic;

  group('formatMoney in English', () {
    test('writes the code before the amount with two decimals', () {
      expect(formatMoney(1250, currency: 'AED', locale: en), 'AED 12.50');
    });

    test('keeps the decimals of whole amounts, of fils and of zero', () {
      expect(formatMoney(1200, currency: 'AED', locale: en), 'AED 12.00');
      expect(formatMoney(5, currency: 'AED', locale: en), 'AED 0.05');
      expect(formatMoney(0, currency: 'AED', locale: en), 'AED 0.00');
    });

    test('groups thousands with a comma', () {
      expect(formatMoney(123450, currency: 'AED', locale: en), 'AED 1,234.50');
      expect(formatMoney(100000000, currency: 'AED', locale: en), 'AED 1,000,000.00');
      expect(formatMoney(99900, currency: 'AED', locale: en), 'AED 999.00');
    });

    test('puts the minus sign before the code', () {
      expect(formatMoney(-1250, currency: 'AED', locale: en), '-AED 12.50');
    });

    test('shows the code of another currency', () {
      expect(formatMoney(1250, currency: 'USD', locale: en), 'USD 12.50');
    });

    test('reads a regional English locale as English', () {
      expect(formatMoney(1250, currency: 'AED', locale: const Locale('en', 'AE')), 'AED 12.50');
    });
  });

  group('formatMoney in Arabic', () {
    test('writes the amount before the symbol, left to right, with Western digits', () {
      expect(formatMoney(1250, currency: 'AED', locale: ar), isolateLeftToRight('12.50 د.إ'));
    });

    test('groups thousands and signs negative amounts', () {
      expect(formatMoney(123450, currency: 'AED', locale: ar), isolateLeftToRight('1,234.50 د.إ'));
      expect(formatMoney(-50, currency: 'AED', locale: ar), isolateLeftToRight('-0.50 د.إ'));
    });

    test('shows the code of another currency, still left to right', () {
      expect(formatMoney(1250, currency: 'USD', locale: ar), isolateLeftToRight('USD 12.50'));
    });
  });
}
