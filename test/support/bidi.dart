/// [text] wrapped the way the app wraps values that must read left to right inside Arabic text (an email address, a
/// phone number, a time): a left-to-right isolate. The marks are built from their code points so that the test files
/// hold no invisible characters.
String ltr(String text) => '${String.fromCharCode(0x2066)}$text${String.fromCharCode(0x2069)}';
