import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/theme/tokens/wasli_layout.dart';

/// The Material 3 window size class of the page width: how much room the layout has.
///
/// Screens are built from the compact layout up and ask this class, never the device type. Compact is below 600
/// logical pixels (phones), medium 600 to 839 (large phones and small tablets), expanded 840 and up. The content
/// column never grows past [WasliLayout.contentMaxWidth].
enum WindowSizeClass {
  /// Below 600: a phone.
  compact,

  /// 600 to 839.
  medium,

  /// 840 and up.
  expanded;

  /// The smallest width of [medium].
  static const double mediumMinWidth = 600;

  /// The smallest width of [expanded].
  static const double expandedMinWidth = 840;

  /// The class of a page [width] in logical pixels.
  static WindowSizeClass fromWidth(double width) {
    if (width >= expandedMinWidth) return expanded;
    if (width >= mediumMinWidth) return medium;
    return compact;
  }

  /// The class of the current window. The widget rebuilds when the width changes, not for other media changes.
  static WindowSizeClass of(BuildContext context) => fromWidth(MediaQuery.widthOf(context));

  /// The page gutter of this class: 16 on a phone, 24 above.
  double get pageGutter => this == compact ? WasliLayout.pageGutterCompact : WasliLayout.pageGutterWide;
}
