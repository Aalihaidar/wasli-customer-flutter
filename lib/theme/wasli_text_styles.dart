import 'package:material_ui/material_ui.dart';

/// The ten text styles of the design, in the one family, Rubik, which carries both Latin and Arabic.
///
/// Sizes, line heights and weights are the design's type scale. Colours are not set here: the text inherits them from
/// the theme. Latin `display` and `heading_1` use a letter spacing of -0.01 em; Arabic never does, because tracking
/// breaks the joined letters. Digits are Western in every language; the number formatters see to it, not these
/// styles.
///
/// The `Text` widgets of Material read the same styles through the text theme ([toTextTheme]); [bodyStrong] has no
/// Material slot and is read through `context.wasliText`.
@immutable
class WasliTextStyles extends ThemeExtension<WasliTextStyles> {
  /// Creates a set of styles from its parts.
  const new({
    required this.display,
    required this.heading1,
    required this.heading2,
    required this.heading3,
    required this.body,
    required this.bodyStrong,
    required this.bodySmall,
    required this.label,
    required this.button,
    required this.caption,
  });

  /// Builds the styles for a language: Arabic gets a letter spacing of 0, every other language the Latin spacing.
  factory forLanguage(String languageCode) {
    final isArabic = languageCode == 'ar';
    // The design's -0.01 em, in the size of the style.
    double tracking(double size) => isArabic ? 0 : -0.01 * size;

    return WasliTextStyles(
      display: _style(size: 32, lineHeight: 40, weight: FontWeight.w700, letterSpacing: tracking(32)),
      heading1: _style(size: 24, lineHeight: 32, weight: FontWeight.w700, letterSpacing: tracking(24)),
      heading2: _style(size: 20, lineHeight: 28, weight: FontWeight.w600),
      heading3: _style(size: 17, lineHeight: 24, weight: FontWeight.w600),
      body: _style(size: 16, lineHeight: 24, weight: FontWeight.w400),
      bodyStrong: _style(size: 16, lineHeight: 24, weight: FontWeight.w500),
      bodySmall: _style(size: 14, lineHeight: 20, weight: FontWeight.w400),
      label: _style(size: 14, lineHeight: 20, weight: FontWeight.w500),
      button: _style(size: 16, lineHeight: 20, weight: FontWeight.w600),
      caption: _style(size: 12, lineHeight: 16, weight: FontWeight.w400),
    );
  }

  /// The family bundled in `assets/fonts/` (never downloaded at start).
  static const fontFamily = 'Rubik';

  /// 32/40, 700: the restaurant name and the empty-state title.
  final TextStyle display;

  /// 24/32, 700: screen titles.
  final TextStyle heading1;

  /// 20/28, 600: section titles.
  final TextStyle heading2;

  /// 17/24, 600: card titles and item names.
  final TextStyle heading3;

  /// 16/24, 400: body text and the chat.
  final TextStyle body;

  /// 16/24, 500: prices.
  final TextStyle bodyStrong;

  /// 14/20, 400: secondary text.
  final TextStyle bodySmall;

  /// 14/20, 500: labels, chips.
  final TextStyle label;

  /// 16/20, 600: buttons.
  final TextStyle button;

  /// 12/16, 400: timestamps and hints.
  final TextStyle caption;

  /// The Material text theme that carries these styles.
  ///
  /// | Material slot | Style |
  /// | --- | --- |
  /// | `displaySmall` | [display] |
  /// | `headlineSmall` | [heading1] |
  /// | `titleLarge` | [heading2] |
  /// | `titleMedium` | [heading3] |
  /// | `bodyLarge`, `bodyMedium` | [body] (`bodyMedium` is what a plain `Text` uses) |
  /// | `bodySmall` | [bodySmall] |
  /// | `labelLarge` | [button] (what Material buttons use) |
  /// | `labelMedium` | [label] |
  /// | `labelSmall` | [caption] |
  ///
  /// The other slots stay with the framework's defaults; the theme sets `fontFamily` so they still use Rubik.
  TextTheme toTextTheme() {
    return TextTheme(
      displaySmall: display,
      headlineSmall: heading1,
      titleLarge: heading2,
      titleMedium: heading3,
      bodyLarge: body,
      bodyMedium: body,
      bodySmall: bodySmall,
      labelLarge: button,
      labelMedium: label,
      labelSmall: caption,
    );
  }

  /// These styles with [color] applied to every one.
  WasliTextStyles withColor(Color color) {
    TextStyle colored(TextStyle style) => style.copyWith(color: color);
    return WasliTextStyles(
      display: colored(display),
      heading1: colored(heading1),
      heading2: colored(heading2),
      heading3: colored(heading3),
      body: colored(body),
      bodyStrong: colored(bodyStrong),
      bodySmall: colored(bodySmall),
      label: colored(label),
      button: colored(button),
      caption: colored(caption),
    );
  }

  @override
  WasliTextStyles copyWith({
    TextStyle? display,
    TextStyle? heading1,
    TextStyle? heading2,
    TextStyle? heading3,
    TextStyle? body,
    TextStyle? bodyStrong,
    TextStyle? bodySmall,
    TextStyle? label,
    TextStyle? button,
    TextStyle? caption,
  }) {
    return WasliTextStyles(
      display: display ?? this.display,
      heading1: heading1 ?? this.heading1,
      heading2: heading2 ?? this.heading2,
      heading3: heading3 ?? this.heading3,
      body: body ?? this.body,
      bodyStrong: bodyStrong ?? this.bodyStrong,
      bodySmall: bodySmall ?? this.bodySmall,
      label: label ?? this.label,
      button: button ?? this.button,
      caption: caption ?? this.caption,
    );
  }

  @override
  WasliTextStyles lerp(WasliTextStyles? other, double t) {
    if (other == null) return this;
    return WasliTextStyles(
      display: TextStyle.lerp(display, other.display, t)!,
      heading1: TextStyle.lerp(heading1, other.heading1, t)!,
      heading2: TextStyle.lerp(heading2, other.heading2, t)!,
      heading3: TextStyle.lerp(heading3, other.heading3, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodyStrong: TextStyle.lerp(bodyStrong, other.bodyStrong, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }

  /// One style of the scale. The weight is set twice on purpose: `fontWeight` for the platform's font matching and an
  /// explicit `wght` variation, so the variable font draws the same weight on every platform and renderer.
  static TextStyle _style({
    required double size,
    required double lineHeight,
    required FontWeight weight,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      fontVariations: [FontVariation.weight(weight.value.toDouble())],
      letterSpacing: letterSpacing,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }
}
