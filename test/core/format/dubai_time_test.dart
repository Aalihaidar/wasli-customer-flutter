import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/format/dubai_time.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';

void main() {
  const en = AppLocales.english;
  const ar = AppLocales.arabic;

  group('toDubaiTime', () {
    test('adds four hours and keeps the fields of the Dubai wall clock', () {
      final dubai = toDubaiTime(DateTime.utc(2026, 11, 25, 10, 5));

      expect([dubai.year, dubai.month, dubai.day, dubai.hour, dubai.minute], [2026, 11, 25, 14, 5]);
    });

    test('moves to the next day after 20:00 UTC and across a year end', () {
      final dubai = toDubaiTime(DateTime.utc(2026, 12, 31, 21, 30));

      expect([dubai.year, dubai.month, dubai.day, dubai.hour, dubai.minute], [2027, 1, 1, 1, 30]);
    });

    test('has no daylight saving: the offset is the same in summer', () {
      expect(toDubaiTime(DateTime.utc(2026, 7, 1, 12)).hour, 16);
    });

    test('treats a local DateTime as the instant it is', () {
      final instant = DateTime.utc(2026, 11, 25, 10).toLocal();

      expect(toDubaiTime(instant).hour, 14);
    });
  });

  group('formatTime', () {
    test('is 24-hour with two digits', () {
      expect(formatTime(DateTime.utc(2026, 11, 25, 10, 5)), '14:05');
      expect(formatTime(DateTime.utc(2026, 11, 25, 20)), '00:00');
      expect(formatTime(DateTime.utc(2026, 11, 25, 19, 59)), '23:59');
    });
  });

  group('formatDate', () {
    test('writes the month in English', () {
      expect(formatDate(DateTime.utc(2026, 11, 25, 10), locale: en), '25 Nov 2026');
      expect(formatDate(DateTime.utc(2026, 1, 3, 10), locale: en), '3 Jan 2026');
    });

    test('writes the month in Arabic with Western digits', () {
      expect(formatDate(DateTime.utc(2026, 11, 25, 10), locale: ar), '25 نوفمبر 2026');
      expect(formatDate(DateTime.utc(2026, 1, 3, 10), locale: ar), '3 يناير 2026');
    });

    test('uses the Dubai day, not the UTC one', () {
      expect(formatDate(DateTime.utc(2026, 11, 25, 21), locale: en), '26 Nov 2026');
    });

    test('has a name for every month in both languages', () {
      for (var month = 1; month <= 12; month++) {
        final instant = DateTime.utc(2026, month, 10, 8);
        expect(formatDate(instant, locale: en), isNot(contains('null')));
        expect(formatDate(instant, locale: ar).split(' ')[1], isNotEmpty);
      }
    });
  });

  group('formatDateTime', () {
    test('joins the date and the time', () {
      final instant = DateTime.utc(2026, 11, 25, 10, 5);

      expect(formatDateTime(instant, locale: en), '25 Nov 2026, 14:05');
      expect(formatDateTime(instant, locale: ar), '25 نوفمبر 2026، 14:05');
    });
  });
}
