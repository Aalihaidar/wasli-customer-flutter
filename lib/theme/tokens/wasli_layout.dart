/// The sizes of the design that are not spacing or radii: page width, control heights and borders.
abstract final class WasliLayout {
  /// 560: the widest the customer content grows; a larger window centres it.
  static const double contentMaxWidth = 560;

  /// 16: the page gutter on a phone.
  static const double pageGutterCompact = 16;

  /// 24: the page gutter on a tablet and wider.
  static const double pageGutterWide = 24;

  /// 48: the smallest tap target, and the height of a button.
  static const double minTapTarget = 48;

  /// 52: the height of a text input.
  static const double inputHeight = 52;

  /// 56: the height of the top bar.
  static const double appBarHeight = 56;

  /// 20: the horizontal padding inside a button.
  static const double buttonPaddingHorizontal = 20;

  /// 1: the width of a decorative border, such as a card line.
  static const double borderWidth = 1;

  /// 1.5: the width of a control border, such as an input outline or a secondary button.
  static const double controlBorderWidth = 1.5;

  /// 2: the width of the focused border and of the focus ring.
  static const double focusBorderWidth = 2;

  /// 0.38: the opacity of a disabled control.
  static const double disabledOpacity = 0.38;
}
