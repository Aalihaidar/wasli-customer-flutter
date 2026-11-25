/// Turns Arabic-Indic digits and separators in [text] into Western ones, leaving everything else as it is.
///
/// The app shows Western digits (0-9) in both languages, and a customer with an Arabic keyboard may type Arabic-Indic
/// ones (U+0660-0669), Eastern Arabic-Indic ones (U+06F0-06F9) or the Arabic decimal (U+066B) and thousands (U+066C)
/// separators. Used wherever the app reads such input (a plate, a code) before it is checked or sent.
String toWesternDigits(String text) {
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    buffer.writeCharCode(_western(rune));
  }
  return buffer.toString();
}

const int _arabicIndicZero = 0x0660;
const int _easternArabicIndicZero = 0x06F0;
const int _arabicDecimalSeparator = 0x066B;
const int _arabicThousandsSeparator = 0x066C;
const int _asciiZero = 0x30;

int _western(int rune) {
  if (rune >= _arabicIndicZero && rune <= _arabicIndicZero + 9) return _asciiZero + rune - _arabicIndicZero;
  if (rune >= _easternArabicIndicZero && rune <= _easternArabicIndicZero + 9) {
    return _asciiZero + rune - _easternArabicIndicZero;
  }
  if (rune == _arabicDecimalSeparator) return 0x2E; // '.'
  if (rune == _arabicThousandsSeparator) return 0x2C; // ','
  return rune;
}
