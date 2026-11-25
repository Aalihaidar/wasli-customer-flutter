import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/format/distance.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/bidi_isolate.dart';

void main() {
  const en = AppLocales.english;
  const ar = AppLocales.arabic;

  group('formatDistance in English', () {
    test('shows metres below one kilometre', () {
      expect(formatDistance(0, locale: en), '0 m');
      expect(formatDistance(120, locale: en), '120 m');
      expect(formatDistance(999, locale: en), '999 m');
    });

    test('shows kilometres with one decimal, rounded to the nearest tenth', () {
      expect(formatDistance(1200, locale: en), '1.2 km');
      expect(formatDistance(1249, locale: en), '1.2 km');
      expect(formatDistance(1250, locale: en), '1.3 km');
      expect(formatDistance(12340, locale: en), '12.3 km');
    });

    test('drops a zero decimal', () {
      expect(formatDistance(1000, locale: en), '1 km');
      expect(formatDistance(1049, locale: en), '1 km');
      expect(formatDistance(3000, locale: en), '3 km');
    });

    test('counts a negative distance as zero', () {
      expect(formatDistance(-5, locale: en), '0 m');
    });
  });

  group('formatDistance in Arabic', () {
    test('uses the Arabic units, left to right, with Western digits', () {
      expect(formatDistance(120, locale: ar), isolateLeftToRight('120 م'));
      expect(formatDistance(1200, locale: ar), isolateLeftToRight('1.2 كم'));
      expect(formatDistance(3000, locale: ar), isolateLeftToRight('3 كم'));
    });
  });
}
