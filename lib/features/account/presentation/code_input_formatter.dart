import 'package:flutter/services.dart';
import 'package:wasli_customer/core/format/western_digits.dart';

/// Keeps only digits in a code field, turns Arabic-Indic ones into Western ones and stops at [length] digits.
///
/// A customer with an Arabic keyboard, or one who pastes "123 456", ends up with `123456`.
class CodeInputFormatter extends TextInputFormatter {
  /// Creates a formatter for codes of [length] digits.
  const new({this.length = 6});

  /// How many digits the code has.
  final int length;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = toWesternDigits(newValue.text).replaceAll(RegExp('[^0-9]'), '');
    final text = digits.length > length ? digits.substring(0, length) : digits;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
