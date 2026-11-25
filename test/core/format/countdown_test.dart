import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/format/countdown.dart';

void main() {
  group('formatCountdown', () {
    test('writes minutes and two-digit seconds', () {
      expect(formatCountdown(const Duration(seconds: 42)), '0:42');
      expect(formatCountdown(const Duration(seconds: 5)), '0:05');
      expect(formatCountdown(const Duration(minutes: 10)), '10:00');
      expect(formatCountdown(const Duration(minutes: 1, seconds: 1)), '1:01');
    });

    test('counts a started second as a whole one, so it never shows 0:00 while time is left', () {
      expect(formatCountdown(const Duration(milliseconds: 100)), '0:01');
      expect(formatCountdown(const Duration(milliseconds: 59500)), '1:00');
    });

    test('shows zero when nothing is left or the time has passed', () {
      expect(formatCountdown(Duration.zero), '0:00');
      expect(formatCountdown(const Duration(seconds: -3)), '0:00');
    });
  });
}
