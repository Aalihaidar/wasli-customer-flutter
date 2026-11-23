import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the Rubik font and its licence are declared in pubspec and present', () async {
    final font = await rootBundle.load('assets/fonts/Rubik-VariableFont_wght.ttf');
    final licence = await rootBundle.loadString('assets/fonts/Rubik-OFL.txt');

    // A TrueType file starts with the version 0x00010000.
    expect(font.getUint32(0), 0x00010000);
    expect(font.lengthInBytes, greaterThan(100000));
    expect(licence, contains('SIL Open Font License'));
  });
}
