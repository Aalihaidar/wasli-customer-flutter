import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/theme/tokens/wasli_layout.dart';
import 'package:wasli_customer/theme/tokens/wasli_radius.dart';
import 'package:wasli_customer/theme/tokens/wasli_spacing.dart';
import 'package:wasli_customer/theme/wasli_colors.dart';
import 'package:wasli_customer/theme/wasli_text_styles.dart';

/// The component themes of the design ("Components" section), built from the tokens.
///
/// Each method returns one Material theme, so the widgets of the app are styled by `ThemeData` and carry no
/// per-screen colours or radii. Borders come first and shadows second: cards, dialogs and sheets have a border and no
/// elevation.
abstract final class WasliComponentThemes {
  /// A button shape: radius_md.
  static const RoundedRectangleBorder _buttonShape = RoundedRectangleBorder(borderRadius: WasliRadius.mdAll);

  /// The padding and size every button shares: 48 high, 20 on each side.
  static const EdgeInsetsGeometry _buttonPadding = EdgeInsetsDirectional.symmetric(
    horizontal: WasliLayout.buttonPaddingHorizontal,
  );

  static const Size _buttonMinimumSize = Size(64, WasliLayout.minTapTarget);

  static Color _disabled(Color color) => color.withValues(alpha: WasliLayout.disabledOpacity);

  /// The focus ring of a button: a 2 px outline in the focus colour while the button has keyboard focus.
  static BorderSide _focusSide(WasliColors c) => BorderSide(color: c.focusRing, width: WasliLayout.focusBorderWidth);

  /// Primary button: [WasliColors.primary] fill, [WasliColors.primaryDark] when pressed, 38 % when disabled.
  static FilledButtonThemeData filledButton(WasliColors c, WasliTextStyles text) {
    return FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(_buttonMinimumSize),
        padding: const WidgetStatePropertyAll(_buttonPadding),
        shape: const WidgetStatePropertyAll(_buttonShape),
        textStyle: WidgetStatePropertyAll(text.button),
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return _disabled(c.primary);
          if (states.contains(WidgetState.pressed)) return c.primaryDark;
          return c.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled) ? _disabled(c.onPrimary) : c.onPrimary,
        ),
        side: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.focused) ? _focusSide(c) : null),
      ),
    );
  }

  /// Secondary button: surface fill and a 1.5 px primary border.
  static OutlinedButtonThemeData outlinedButton(WasliColors c, WasliTextStyles text) {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(_buttonMinimumSize),
        padding: const WidgetStatePropertyAll(_buttonPadding),
        shape: const WidgetStatePropertyAll(_buttonShape),
        textStyle: WidgetStatePropertyAll(text.button),
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(c.surface),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled) ? _disabled(c.primary) : c.primary,
        ),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return _focusSide(c);
          final color = states.contains(WidgetState.disabled) ? _disabled(c.primary) : c.primary;
          return BorderSide(color: color, width: WasliLayout.controlBorderWidth);
        }),
      ),
    );
  }

  /// Tertiary button: no fill, the primary colour for the label.
  static TextButtonThemeData textButton(WasliColors c, WasliTextStyles text) {
    return TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(_buttonMinimumSize),
        padding: const WidgetStatePropertyAll(_buttonPadding),
        shape: const WidgetStatePropertyAll(_buttonShape),
        textStyle: WidgetStatePropertyAll(text.button),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled) ? _disabled(c.primary) : c.primary,
        ),
        side: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.focused) ? _focusSide(c) : null),
      ),
    );
  }

  /// Text input: 52 high, surface fill, a 1.5 px outline that becomes 2 px primary on focus, error outline and
  /// message when invalid. The label sits above the field (the field widget draws it), never as a placeholder.
  static InputDecorationThemeData inputDecoration(WasliColors c, WasliTextStyles text) {
    OutlineInputBorder border(Color color, {double width = WasliLayout.controlBorderWidth}) {
      return OutlineInputBorder(
        borderRadius: WasliRadius.mdAll,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    // 52 high: the 24 px line of the body style plus 14 px above and below.
    const verticalPadding = (WasliLayout.inputHeight - 24) / 2;

    return InputDecorationThemeData(
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: WasliSpacing.space3, vertical: verticalPadding),
      constraints: const BoxConstraints(minHeight: WasliLayout.inputHeight),
      hintStyle: text.body.copyWith(color: c.textMuted),
      errorStyle: text.caption.copyWith(color: c.error),
      helperStyle: text.caption.copyWith(color: c.textMuted),
      border: border(c.borderInput),
      enabledBorder: border(c.borderInput),
      focusedBorder: border(c.primary, width: WasliLayout.focusBorderWidth),
      errorBorder: border(c.error),
      focusedErrorBorder: border(c.error, width: WasliLayout.focusBorderWidth),
      disabledBorder: border(_disabled(c.borderInput)),
    );
  }

  /// Card: surface, a 1 px subtle border, radius_md, no elevation.
  static CardThemeData card(WasliColors c) {
    return CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: const Color(0x00000000),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: WasliRadius.mdAll,
        side: BorderSide(color: c.borderSubtle),
      ),
    );
  }

  /// Top bar: primary fill, 56 high, the title in `heading_2`.
  static AppBarThemeData appBar(WasliColors c, WasliTextStyles text) {
    return AppBarThemeData(
      backgroundColor: c.primary,
      foregroundColor: c.onPrimary,
      surfaceTintColor: const Color(0x00000000),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: WasliLayout.appBarHeight,
      titleTextStyle: text.heading2.copyWith(color: c.onPrimary),
    );
  }

  /// Dialog: surface, radius_lg, a subtle border instead of a shadow.
  static DialogThemeData dialog(WasliColors c, WasliTextStyles text) {
    return DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: const Color(0x00000000),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: WasliRadius.lgAll,
        side: BorderSide(color: c.borderSubtle),
      ),
      titleTextStyle: text.heading2.copyWith(color: c.text),
      contentTextStyle: text.body.copyWith(color: c.text),
    );
  }

  /// Bottom sheet: surface, radius_lg on the top corners, no wider than the content column.
  static BottomSheetThemeData bottomSheet(WasliColors c) {
    return BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: const Color(0x00000000),
      elevation: 0,
      modalElevation: 0,
      showDragHandle: true,
      dragHandleColor: c.borderInput,
      clipBehavior: Clip.antiAlias,
      constraints: const BoxConstraints(maxWidth: WasliLayout.contentMaxWidth),
      shape: RoundedRectangleBorder(
        borderRadius: WasliRadius.lgTop,
        side: BorderSide(color: c.borderSubtle),
      ),
    );
  }

  /// Snack bar: floating, radius_md, the inverse colours of the scheme.
  static SnackBarThemeData snackBar(WasliColors c, WasliTextStyles text) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.text,
      contentTextStyle: text.body.copyWith(color: c.background),
      actionTextColor: c.accent,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: WasliRadius.mdAll),
      width: WasliLayout.contentMaxWidth,
    );
  }

  /// Divider: the subtle border colour, 1 px.
  static DividerThemeData divider(WasliColors c) {
    return DividerThemeData(color: c.borderSubtle, thickness: WasliLayout.borderWidth, space: WasliLayout.borderWidth);
  }

  /// Progress indicators: mustard on the subtle track.
  static ProgressIndicatorThemeData progressIndicator(WasliColors c) {
    return ProgressIndicatorThemeData(
      color: c.accent,
      linearTrackColor: c.borderSubtle,
      circularTrackColor: c.borderSubtle,
    );
  }
}
