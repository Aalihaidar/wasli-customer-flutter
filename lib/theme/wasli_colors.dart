import 'package:material_ui/material_ui.dart';

/// The colour tokens of the "Ink & Mustard" design, for one brightness.
///
/// This is the single place where the hex values live: the [ColorScheme] is derived from it
/// (`WasliColorSchemes`), and widgets read what the scheme has no slot for through `context.wasli`. The values are
/// copied from the design page and invent none; a new colour is added to the design page first, with its contrast
/// check (`test/theme/contrast_test.dart` checks the pairs below).
///
/// Mustard ([accent]) is a fill or a highlight, never text on a light background; text on it is [onAccent].
@immutable
class WasliColors extends ThemeExtension<WasliColors> {
  /// Creates a set of tokens.
  const new({
    required this.primary,
    required this.primaryDark,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.background,
    required this.surface,
    required this.text,
    required this.textMuted,
    required this.borderSubtle,
    required this.borderInput,
    required this.link,
    required this.focusRing,
    required this.error,
    required this.onError,
    required this.statusWarnBackground,
    required this.statusWarnForeground,
    required this.statusInfoBackground,
    required this.statusInfoForeground,
    required this.statusOkBackground,
    required this.statusOkForeground,
    required this.statusBadBackground,
    required this.statusBadForeground,
  });

  /// The light tokens.
  static const light = WasliColors(
    primary: Color(0xFF1F2A44),
    primaryDark: Color(0xFF121A2E),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFF2B705),
    onAccent: Color(0xFF121A2E),
    background: Color(0xFFFAFAF7),
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF121A2E),
    textMuted: Color(0xFF5B6475),
    borderSubtle: Color(0xFFE3E4E0),
    borderInput: Color(0xFF7E869A),
    link: Color(0xFF2C4FA3),
    focusRing: Color(0xFF1F2A44),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    statusWarnBackground: Color(0xFFFDF0D0),
    statusWarnForeground: Color(0xFF7A4B00),
    statusInfoBackground: Color(0xFFDBEAFE),
    statusInfoForeground: Color(0xFF1E3A8A),
    statusOkBackground: Color(0xFFDFF3E4),
    statusOkForeground: Color(0xFF14532D),
    statusBadBackground: Color(0xFFFDE2E0),
    statusBadForeground: Color(0xFF8A1C14),
  );

  /// The dark tokens.
  static const dark = WasliColors(
    primary: Color(0xFFF2B705),
    primaryDark: Color(0xFFC99700),
    onPrimary: Color(0xFF121A2E),
    accent: Color(0xFFF2B705),
    onAccent: Color(0xFF121A2E),
    background: Color(0xFF0F1626),
    surface: Color(0xFF182036),
    text: Color(0xFFF2F1EC),
    textMuted: Color(0xFFA9B0C0),
    borderSubtle: Color(0xFF2A3550),
    borderInput: Color(0xFF7B849C),
    link: Color(0xFF8FB0FF),
    focusRing: Color(0xFFF2B705),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF4D1410),
    statusWarnBackground: Color(0xFF4A3300),
    statusWarnForeground: Color(0xFFFFDF9B),
    statusInfoBackground: Color(0xFF14305F),
    statusInfoForeground: Color(0xFFBCD4FF),
    statusOkBackground: Color(0xFF123D24),
    statusOkForeground: Color(0xFFB7EFC8),
    statusBadBackground: Color(0xFF4D1410),
    statusBadForeground: Color(0xFFFFC6C0),
  );

  /// Main actions, links, the top bar and the selected state. Mustard in the dark theme.
  final Color primary;

  /// The pressed state of [primary]. Not a text colour in the dark theme.
  final Color primaryDark;

  /// Content on [primary].
  final Color onPrimary;

  /// Badges, progress and price chips; the same mustard in both themes.
  final Color accent;

  /// Content on [accent].
  final Color onAccent;

  /// The page behind everything.
  final Color background;

  /// Cards, sheets, inputs and the restaurant's chat bubbles.
  final Color surface;

  /// Body text and headings.
  final Color text;

  /// Secondary text.
  final Color textMuted;

  /// Card lines and dividers: decoration only, never the only cue.
  final Color borderSubtle;

  /// Input outlines, which need 3:1 against the page.
  final Color borderInput;

  /// Links in running text.
  final Color link;

  /// The 2 px outline of the focused control.
  final Color focusRing;

  /// Errors and destructive actions.
  final Color error;

  /// Content on [error].
  final Color onError;

  /// Background of the "placed" pill. Status pills always carry a text label, never colour alone.
  final Color statusWarnBackground;

  /// Text of the "placed" pill.
  final Color statusWarnForeground;

  /// Background of the "accepted" pill.
  final Color statusInfoBackground;

  /// Text of the "accepted" pill.
  final Color statusInfoForeground;

  /// Background of the "ready" pill.
  final Color statusOkBackground;

  /// Text of the "ready" pill.
  final Color statusOkForeground;

  /// Background of the "rejected" pill.
  final Color statusBadBackground;

  /// Text of the "rejected" pill.
  final Color statusBadForeground;

  @override
  WasliColors copyWith({
    Color? primary,
    Color? primaryDark,
    Color? onPrimary,
    Color? accent,
    Color? onAccent,
    Color? background,
    Color? surface,
    Color? text,
    Color? textMuted,
    Color? borderSubtle,
    Color? borderInput,
    Color? link,
    Color? focusRing,
    Color? error,
    Color? onError,
    Color? statusWarnBackground,
    Color? statusWarnForeground,
    Color? statusInfoBackground,
    Color? statusInfoForeground,
    Color? statusOkBackground,
    Color? statusOkForeground,
    Color? statusBadBackground,
    Color? statusBadForeground,
  }) {
    return WasliColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderInput: borderInput ?? this.borderInput,
      link: link ?? this.link,
      focusRing: focusRing ?? this.focusRing,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      statusWarnBackground: statusWarnBackground ?? this.statusWarnBackground,
      statusWarnForeground: statusWarnForeground ?? this.statusWarnForeground,
      statusInfoBackground: statusInfoBackground ?? this.statusInfoBackground,
      statusInfoForeground: statusInfoForeground ?? this.statusInfoForeground,
      statusOkBackground: statusOkBackground ?? this.statusOkBackground,
      statusOkForeground: statusOkForeground ?? this.statusOkForeground,
      statusBadBackground: statusBadBackground ?? this.statusBadBackground,
      statusBadForeground: statusBadForeground ?? this.statusBadForeground,
    );
  }

  @override
  WasliColors lerp(WasliColors? other, double t) {
    if (other == null) return this;
    return WasliColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderInput: Color.lerp(borderInput, other.borderInput, t)!,
      link: Color.lerp(link, other.link, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      statusWarnBackground: Color.lerp(statusWarnBackground, other.statusWarnBackground, t)!,
      statusWarnForeground: Color.lerp(statusWarnForeground, other.statusWarnForeground, t)!,
      statusInfoBackground: Color.lerp(statusInfoBackground, other.statusInfoBackground, t)!,
      statusInfoForeground: Color.lerp(statusInfoForeground, other.statusInfoForeground, t)!,
      statusOkBackground: Color.lerp(statusOkBackground, other.statusOkBackground, t)!,
      statusOkForeground: Color.lerp(statusOkForeground, other.statusOkForeground, t)!,
      statusBadBackground: Color.lerp(statusBadBackground, other.statusBadBackground, t)!,
      statusBadForeground: Color.lerp(statusBadForeground, other.statusBadForeground, t)!,
    );
  }
}
