import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/theme/theme.dart';

void main() {
  const english = Locale('en');
  const arabic = Locale('ar');

  group('the page and the scheme', () {
    test('light: the page is the background token, the scheme is derived from the tokens', () {
      final theme = WasliTheme.light(english);

      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, WasliColors.light.background);
      expect(theme.colorScheme, WasliColorSchemes.light);
    });

    test('dark: the page is the dark background token', () {
      final theme = WasliTheme.dark(english);

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, WasliColors.dark.background);
      expect(theme.colorScheme, WasliColorSchemes.dark);
    });

    test('each theme carries its own tokens and text styles as extensions', () {
      expect(WasliTheme.light(english).extension<WasliColors>(), WasliColors.light);
      expect(WasliTheme.dark(english).extension<WasliColors>(), WasliColors.dark);
      expect(WasliTheme.light(english).extension<WasliTextStyles>(), isNotNull);
    });
  });

  group('typography', () {
    test('every text style of the theme uses Rubik', () {
      final textTheme = WasliTheme.light(english).textTheme;

      for (final style in [
        textTheme.displayLarge,
        textTheme.headlineMedium,
        textTheme.titleSmall,
        textTheme.bodyMedium,
        textTheme.labelLarge,
        textTheme.labelSmall,
      ]) {
        expect(style!.fontFamily, 'Rubik');
      }
    });

    test('the default Text style is the body style, in the text colour', () {
      final style = WasliTheme.light(english).textTheme.bodyMedium!;

      expect(style.fontSize, 16);
      expect(style.color, WasliColors.light.text);
    });

    test('the Arabic theme has no letter spacing on the large styles', () {
      expect(WasliTheme.light(arabic).textTheme.displaySmall!.letterSpacing, 0);
      expect(WasliTheme.light(english).textTheme.displaySmall!.letterSpacing, isNot(0));
    });

    test('the colour of the text follows the theme', () {
      expect(WasliTheme.dark(english).textTheme.bodyMedium!.color, WasliColors.dark.text);
    });
  });

  group('components', () {
    final light = WasliTheme.light(english);
    const colors = WasliColors.light;

    Set<WidgetState> states(WidgetState state) => {state};

    test('a filled button is 48 high, primary, darker when pressed, faded when disabled', () {
      final style = light.filledButtonTheme.style!;

      expect(style.minimumSize!.resolve({})!.height, 48);
      expect(style.backgroundColor!.resolve({}), colors.primary);
      expect(style.backgroundColor!.resolve(states(WidgetState.pressed)), colors.primaryDark);
      expect(style.backgroundColor!.resolve(states(WidgetState.disabled))!.a, closeTo(0.38, 0.01));
      expect(style.foregroundColor!.resolve({}), colors.onPrimary);
      expect(style.textStyle!.resolve({})!.fontWeight, FontWeight.w600);
    });

    test('a secondary button has a surface fill and a 1.5 px primary border', () {
      final style = light.outlinedButtonTheme.style!;
      final side = style.side!.resolve({})!;

      expect(style.backgroundColor!.resolve({}), colors.surface);
      expect(side.color, colors.primary);
      expect(side.width, 1.5);
    });

    test('a focused button shows a 2 px focus ring', () {
      for (final style in [
        light.filledButtonTheme.style!,
        light.outlinedButtonTheme.style!,
        light.textButtonTheme.style!,
      ]) {
        final side = style.side!.resolve(states(WidgetState.focused))!;

        expect(side.color, colors.focusRing);
        expect(side.width, 2);
      }
    });

    test('an input has a 1.5 px outline, 2 px primary when focused, and error outlines', () {
      final theme = light.inputDecorationTheme;
      BorderSide sideOf(InputBorder? border) => (border! as OutlineInputBorder).borderSide;

      expect(theme.filled, isTrue);
      expect(theme.fillColor, colors.surface);
      expect(theme.constraints!.minHeight, 52);
      expect(sideOf(theme.enabledBorder).width, 1.5);
      expect(sideOf(theme.enabledBorder).color, colors.borderInput);
      expect(sideOf(theme.focusedBorder).width, 2);
      expect(sideOf(theme.focusedBorder).color, colors.primary);
      expect(sideOf(theme.errorBorder).color, colors.error);
      expect((theme.enabledBorder! as OutlineInputBorder).borderRadius, WasliRadius.mdAll);
    });

    test('a card is a surface with a subtle 1 px border and no elevation', () {
      final card = light.cardTheme;
      final shape = card.shape! as RoundedRectangleBorder;

      expect(card.color, colors.surface);
      expect(card.elevation, 0);
      expect(shape.side.color, colors.borderSubtle);
      expect(shape.side.width, 1);
      expect(shape.borderRadius, WasliRadius.mdAll);
    });

    test('the top bar is primary and 56 high', () {
      final bar = light.appBarTheme;

      expect(bar.backgroundColor, colors.primary);
      expect(bar.foregroundColor, colors.onPrimary);
      expect(bar.toolbarHeight, 56);
      expect(bar.centerTitle, isFalse);
    });

    test('a sheet has radius_lg on its top corners and stays within the content column', () {
      final sheet = light.bottomSheetTheme;
      final shape = sheet.shape! as RoundedRectangleBorder;

      expect(shape.borderRadius, WasliRadius.lgTop);
      expect(sheet.constraints!.maxWidth, 560);
      expect(sheet.backgroundColor, colors.surface);
    });

    test('a dialog is a surface with radius_lg and no shadow', () {
      final dialog = light.dialogTheme;

      expect(dialog.backgroundColor, colors.surface);
      expect(dialog.elevation, 0);
      expect((dialog.shape! as RoundedRectangleBorder).borderRadius, WasliRadius.lgAll);
    });

    test('progress is mustard on a subtle track, in both themes', () {
      expect(light.progressIndicatorTheme.color, WasliColors.light.accent);
      expect(WasliTheme.dark(english).progressIndicatorTheme.color, WasliColors.dark.accent);
    });
  });
}
