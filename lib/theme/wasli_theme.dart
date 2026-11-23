import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/theme/wasli_color_schemes.dart';
import 'package:wasli_customer/theme/wasli_colors.dart';
import 'package:wasli_customer/theme/wasli_component_themes.dart';
import 'package:wasli_customer/theme/wasli_text_styles.dart';

/// The [ThemeData] of the app: "Ink & Mustard", light and dark.
///
/// The theme depends on the language only for the type: Arabic text has no letter spacing. Build it for the active
/// locale and rebuild it when the locale changes:
///
/// ```dart
/// MaterialApp(
///   theme: WasliTheme.light(locale),
///   darkTheme: WasliTheme.dark(locale),
///   themeMode: ThemeMode.system,
/// )
/// ```
abstract final class WasliTheme {
  /// The light theme for [locale].
  static ThemeData light(Locale locale) => _build(WasliColors.light, Brightness.light, locale);

  /// The dark theme for [locale].
  static ThemeData dark(Locale locale) => _build(WasliColors.dark, Brightness.dark, locale);

  static ThemeData _build(WasliColors colors, Brightness brightness, Locale locale) {
    final scheme = WasliColorSchemes.fromTokens(colors, brightness);
    final styles = WasliTextStyles.forLanguage(locale.languageCode);
    final textTheme = styles.toTextTheme().apply(bodyColor: colors.text, displayColor: colors.text);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      fontFamily: WasliTextStyles.fontFamily,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      dividerColor: colors.borderSubtle,
      focusColor: colors.focusRing.withValues(alpha: 0.12),
      extensions: [colors, styles.withColor(colors.text)],
      filledButtonTheme: WasliComponentThemes.filledButton(colors, styles),
      outlinedButtonTheme: WasliComponentThemes.outlinedButton(colors, styles),
      textButtonTheme: WasliComponentThemes.textButton(colors, styles),
      inputDecorationTheme: WasliComponentThemes.inputDecoration(colors, styles),
      cardTheme: WasliComponentThemes.card(colors),
      appBarTheme: WasliComponentThemes.appBar(colors, styles),
      dialogTheme: WasliComponentThemes.dialog(colors, styles),
      bottomSheetTheme: WasliComponentThemes.bottomSheet(colors),
      snackBarTheme: WasliComponentThemes.snackBar(colors, styles),
      dividerTheme: WasliComponentThemes.divider(colors),
      progressIndicatorTheme: WasliComponentThemes.progressIndicator(colors),
    );
  }
}

/// Reads the design tokens that the Material [ColorScheme] and [TextTheme] have no slot for.
extension WasliThemeContext on BuildContext {
  /// The colour tokens of the active theme, for example `context.wasli.statusWarnBackground`.
  WasliColors get wasli => Theme.of(this).extension<WasliColors>()!;

  /// The text styles of the active theme, for example `context.wasliText.bodyStrong` for a price.
  WasliTextStyles get wasliText => Theme.of(this).extension<WasliTextStyles>()!;
}
