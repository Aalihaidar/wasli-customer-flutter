import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/l10n/bidi_isolate.dart';

void main() {
  test('wraps the text in a left-to-right isolate and its closing mark', () {
    final isolated = isolateLeftToRight('AED 12.50');

    expect(isolated.runes.first, 0x2066);
    expect(isolated.runes.last, 0x2069);
    expect(isolated.substring(1, isolated.length - 1), 'AED 12.50');
  });

  test('adds nothing but the two marks, and keeps digits and letters as they are', () {
    expect(isolateLeftToRight('ABC 1234').length, 'ABC 1234'.length + 2);
    expect(isolateLeftToRight(''), String.fromCharCodes([0x2066, 0x2069]));
  });
}
