import 'package:material_ui/material_ui.dart';

/// The corner radii of the design, as numbers and as ready-made [BorderRadius] values.
abstract final class WasliRadius {
  /// 8: small elements such as tags.
  static const double sm = 8;

  /// 12: buttons, inputs and cards.
  static const double md = 12;

  /// 16: sheets, dialogs and chat bubbles.
  static const double lg = 16;

  /// 999: pills and circles.
  static const double full = 999;

  /// [sm] on every corner.
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));

  /// [md] on every corner.
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));

  /// [lg] on every corner.
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));

  /// [lg] on the top corners only, for bottom sheets.
  static const BorderRadius lgTop = BorderRadius.vertical(top: Radius.circular(lg));

  /// [full] on every corner.
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
}
