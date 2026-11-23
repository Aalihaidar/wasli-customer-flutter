import 'package:material_ui/material_ui.dart';

/// The depth levels of the design. Borders come first and shadows second, so most surfaces use [level0].
abstract final class WasliElevation {
  /// Shadow colour of the design, ink at 8 % opacity.
  static const Color _shadowLow = Color(0x14121A2E);

  /// Shadow colour of the design, ink at 16 % opacity.
  static const Color _shadowHigh = Color(0x29121A2E);

  /// `elevation_0`: no shadow, the surface is separated by a 1 px subtle border.
  static const List<BoxShadow> level0 = [];

  /// `elevation_1`: `0 1px 2px` at 8 %, for raised cards.
  static const List<BoxShadow> level1 = [BoxShadow(color: _shadowLow, offset: Offset(0, 1), blurRadius: 2)];

  /// `elevation_2`: `0 8px 24px` at 16 %, for floating surfaces.
  static const List<BoxShadow> level2 = [BoxShadow(color: _shadowHigh, offset: Offset(0, 8), blurRadius: 24)];
}
