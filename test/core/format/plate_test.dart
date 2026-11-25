import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/format/plate.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/bidi_isolate.dart';

void main() {
  group('normalizePlate', () {
    test('trims, collapses spaces and upper-cases Latin letters', () {
      expect(normalizePlate('  ab   1234 '), 'AB 1234');
    });

    test('turns Arabic-Indic digits into Western ones', () {
      expect(normalizePlate('A ١٢٣٤'), 'A 1234');
      expect(normalizePlate('۱۲۳۴'), '1234');
    });

    test('keeps Arabic letters and dashes as typed', () {
      expect(normalizePlate('أ ب-12'), 'أ ب-12');
    });

    test('turns whitespace only into an empty text', () {
      expect(normalizePlate('   \t '), '');
    });
  });

  group('formatPlate', () {
    test('is unchanged in English', () {
      expect(formatPlate('AB 1234', locale: AppLocales.english), 'AB 1234');
    });

    test('is kept left to right in Arabic', () {
      expect(formatPlate('AB 1234', locale: AppLocales.arabic), isolateLeftToRight('AB 1234'));
    });
  });
}
