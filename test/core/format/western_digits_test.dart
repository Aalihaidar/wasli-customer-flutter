import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/format/western_digits.dart';

void main() {
  group('toWesternDigits', () {
    test('turns Arabic-Indic digits into Western ones', () {
      expect(toWesternDigits('٠١٢٣٤٥٦٧٨٩'), '0123456789');
    });

    test('turns Eastern Arabic-Indic digits into Western ones', () {
      expect(toWesternDigits('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
    });

    test('turns the Arabic decimal and thousands separators into a point and a comma', () {
      expect(toWesternDigits('١٬٢٣٤٫٥٠'), '1,234.50');
    });

    test('leaves Western digits, letters and other text as they are', () {
      expect(toWesternDigits('A 12-b ج'), 'A 12-b ج');
      expect(toWesternDigits(''), '');
    });
  });
}
