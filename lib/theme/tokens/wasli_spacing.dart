/// The spacing scale of the design (`space_1` to `space_8`), in logical pixels.
///
/// Use these values for every gap, padding and margin; no widget writes a raw number.
abstract final class WasliSpacing {
  /// 4: the smallest gap, between an icon and its label.
  static const double space1 = 4;

  /// 8: between related elements.
  static const double space2 = 8;

  /// 12: inner padding of compact controls.
  static const double space3 = 12;

  /// 16: the default padding and the phone page gutter.
  static const double space4 = 16;

  /// 24: between sections and the tablet page gutter.
  static const double space5 = 24;

  /// 32: large gaps between blocks.
  static const double space6 = 32;

  /// 48: empty-state spacing.
  static const double space7 = 48;

  /// 64: the largest gap.
  static const double space8 = 64;
}
