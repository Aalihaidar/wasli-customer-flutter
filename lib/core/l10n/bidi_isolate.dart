/// Left-to-right isolate (U+2066): starts a run of text that keeps its own direction.
final String _leftToRightIsolate = String.fromCharCode(0x2066);

/// Pop directional isolate (U+2069): ends the run started by [_leftToRightIsolate].
final String _popDirectionalIsolate = String.fromCharCode(0x2069);

/// Keeps [text] in its own left-to-right order inside right-to-left text.
///
/// Prices (`AED 12.50`), plates and distances stay left to right in Arabic (design page, "Right to left"). Without the
/// isolate the Unicode bidirectional algorithm can move a trailing unit or sign to the wrong side of the number.
String isolateLeftToRight(String text) => '$_leftToRightIsolate$text$_popDirectionalIsolate';
