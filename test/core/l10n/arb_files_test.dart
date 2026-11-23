import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _readArb(String locale) {
  final file = File('l10n/app_$locale.arb');
  return jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
}

Set<String> _messageKeys(Map<String, Object?> arb) => arb.keys.where((key) => !key.startsWith('@')).toSet();

Set<String> _placeholders(String message) => RegExp(r'\{(\w+)').allMatches(message).map((m) => m[1]!).toSet();

/// The ARB files are the one source of the app's own labels. These tests keep the two languages in step, so a label is
/// never added in English only.
void main() {
  final english = _readArb('en');
  final arabic = _readArb('ar');

  test('Arabic translates exactly the messages of the English template', () {
    expect(_messageKeys(arabic), _messageKeys(english));
  });

  test('every English message has a description for translators', () {
    for (final key in _messageKeys(english)) {
      final metadata = english['@$key'] as Map<String, Object?>?;

      expect(metadata?['description'], isA<String>().having((d) => d.trim(), 'description', isNotEmpty), reason: key);
    }
  });

  test('Arabic messages use the same placeholders as the English ones', () {
    for (final key in _messageKeys(english)) {
      expect(_placeholders(arabic[key]! as String), _placeholders(english[key]! as String), reason: key);
    }
  });

  test('no message is left empty', () {
    for (final arb in [english, arabic]) {
      for (final key in _messageKeys(arb)) {
        expect((arb[key]! as String).trim(), isNotEmpty, reason: key);
      }
    }
  });

  test('the files declare their own language', () {
    expect(english['@@locale'], 'en');
    expect(arabic['@@locale'], 'ar');
  });

  test('each language is named in its own language, the same in every translation', () {
    for (final arb in [english, arabic]) {
      expect(arb['languageEnglish'], 'English');
      expect(arb['languageArabic'], 'العربية');
    }
  });

  test('the brand name stays in Latin letters in Arabic', () {
    expect(arabic['appTitle'], english['appTitle']);
  });

  test('the Arabic messages contain no Arabic-Indic digits (digits are always Western)', () {
    final arabicIndic = RegExp('[٠-٩۰-۹]');

    for (final key in _messageKeys(arabic)) {
      expect(arabicIndic.hasMatch(arabic[key]! as String), isFalse, reason: key);
    }
  });
}
