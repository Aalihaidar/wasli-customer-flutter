import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/theme/wasli_colors.dart';

/// The Material [ColorScheme] of each brightness, derived from the [WasliColors] tokens.
///
/// Only slots the design names are set from tokens. The `surfaceContainer*` roles are all the plain surface, so no
/// Material widget draws a tint the design does not have ("borders first, shadows second"), and `surfaceTint` is
/// transparent for the same reason. The page colour is not a scheme slot here: the theme sets it as the scaffold
/// background.
abstract final class WasliColorSchemes {
  /// The light scheme.
  static final ColorScheme light = fromTokens(WasliColors.light, Brightness.light);

  /// The dark scheme.
  static final ColorScheme dark = fromTokens(WasliColors.dark, Brightness.dark);

  /// Builds the scheme for [tokens] at [brightness].
  static ColorScheme fromTokens(WasliColors tokens, Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: tokens.primary,
      onPrimary: tokens.onPrimary,
      primaryContainer: tokens.primary,
      onPrimaryContainer: tokens.onPrimary,
      secondary: tokens.accent,
      onSecondary: tokens.onAccent,
      secondaryContainer: tokens.accent,
      onSecondaryContainer: tokens.onAccent,
      error: tokens.error,
      onError: tokens.onError,
      surface: tokens.surface,
      onSurface: tokens.text,
      onSurfaceVariant: tokens.textMuted,
      outline: tokens.borderInput,
      outlineVariant: tokens.borderSubtle,
      shadow: tokens.primaryDark,
      scrim: tokens.primaryDark,
      inverseSurface: tokens.text,
      onInverseSurface: tokens.background,
      inversePrimary: tokens.accent,
      surfaceTint: const Color(0x00000000),
      surfaceContainerLowest: tokens.surface,
      surfaceContainerLow: tokens.surface,
      surfaceContainer: tokens.surface,
      surfaceContainerHigh: tokens.surface,
      surfaceContainerHighest: tokens.surface,
    );
  }
}
