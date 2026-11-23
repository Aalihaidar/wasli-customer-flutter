import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/theme/theme.dart';

void main() {
  group('the tokens are the values of the design page', () {
    test('light', () {
      const c = WasliColors.light;

      expect(c.primary, const Color(0xFF1F2A44));
      expect(c.primaryDark, const Color(0xFF121A2E));
      expect(c.onPrimary, const Color(0xFFFFFFFF));
      expect(c.accent, const Color(0xFFF2B705));
      expect(c.onAccent, const Color(0xFF121A2E));
      expect(c.background, const Color(0xFFFAFAF7));
      expect(c.surface, const Color(0xFFFFFFFF));
      expect(c.text, const Color(0xFF121A2E));
      expect(c.textMuted, const Color(0xFF5B6475));
      expect(c.borderSubtle, const Color(0xFFE3E4E0));
      expect(c.borderInput, const Color(0xFF7E869A));
      expect(c.link, const Color(0xFF2C4FA3));
      expect(c.focusRing, const Color(0xFF1F2A44));
      expect(c.error, const Color(0xFFB3261E));
      expect(c.onError, const Color(0xFFFFFFFF));
      expect(c.statusWarnBackground, const Color(0xFFFDF0D0));
      expect(c.statusWarnForeground, const Color(0xFF7A4B00));
      expect(c.statusInfoBackground, const Color(0xFFDBEAFE));
      expect(c.statusInfoForeground, const Color(0xFF1E3A8A));
      expect(c.statusOkBackground, const Color(0xFFDFF3E4));
      expect(c.statusOkForeground, const Color(0xFF14532D));
      expect(c.statusBadBackground, const Color(0xFFFDE2E0));
      expect(c.statusBadForeground, const Color(0xFF8A1C14));
    });

    test('dark', () {
      const c = WasliColors.dark;

      expect(c.primary, const Color(0xFFF2B705));
      expect(c.primaryDark, const Color(0xFFC99700));
      expect(c.onPrimary, const Color(0xFF121A2E));
      expect(c.accent, const Color(0xFFF2B705));
      expect(c.onAccent, const Color(0xFF121A2E));
      expect(c.background, const Color(0xFF0F1626));
      expect(c.surface, const Color(0xFF182036));
      expect(c.text, const Color(0xFFF2F1EC));
      expect(c.textMuted, const Color(0xFFA9B0C0));
      expect(c.borderSubtle, const Color(0xFF2A3550));
      expect(c.borderInput, const Color(0xFF7B849C));
      expect(c.link, const Color(0xFF8FB0FF));
      expect(c.focusRing, const Color(0xFFF2B705));
      expect(c.error, const Color(0xFFFFB4AB));
      expect(c.onError, const Color(0xFF4D1410));
      expect(c.statusWarnBackground, const Color(0xFF4A3300));
      expect(c.statusWarnForeground, const Color(0xFFFFDF9B));
      expect(c.statusInfoBackground, const Color(0xFF14305F));
      expect(c.statusInfoForeground, const Color(0xFFBCD4FF));
      expect(c.statusOkBackground, const Color(0xFF123D24));
      expect(c.statusOkForeground, const Color(0xFFB7EFC8));
      expect(c.statusBadBackground, const Color(0xFF4D1410));
      expect(c.statusBadForeground, const Color(0xFFFFC6C0));
    });
  });

  group('WasliColors as a theme extension', () {
    test('copyWith replaces only the given colours', () {
      const red = Color(0xFFFF0000);
      final copy = WasliColors.light.copyWith(link: red);

      expect(copy.link, red);
      expect(copy.primary, WasliColors.light.primary);
      expect(copy.statusBadForeground, WasliColors.light.statusBadForeground);
    });

    test('lerp at the ends returns each side, and a null other returns this', () {
      final atStart = WasliColors.light.lerp(WasliColors.dark, 0);
      final atEnd = WasliColors.light.lerp(WasliColors.dark, 1);

      expect(atStart.background, WasliColors.light.background);
      expect(atEnd.background, WasliColors.dark.background);
      expect(atEnd.statusOkForeground, WasliColors.dark.statusOkForeground);
      expect(WasliColors.light.lerp(null, 0.5), same(WasliColors.light));
    });

    test('lerp in the middle blends the colours', () {
      final middle = WasliColors.light.lerp(WasliColors.dark, 0.5);

      expect(middle.background, Color.lerp(WasliColors.light.background, WasliColors.dark.background, 0.5));
    });
  });

  group('the colour schemes are derived from the tokens', () {
    test('light', () {
      final scheme = WasliColorSchemes.light;
      const c = WasliColors.light;

      expect(scheme.brightness, Brightness.light);
      expect(scheme.primary, c.primary);
      expect(scheme.onPrimary, c.onPrimary);
      expect(scheme.secondary, c.accent);
      expect(scheme.onSecondary, c.onAccent);
      expect(scheme.error, c.error);
      expect(scheme.onError, c.onError);
      expect(scheme.surface, c.surface);
      expect(scheme.onSurface, c.text);
      expect(scheme.outline, c.borderInput);
      expect(scheme.outlineVariant, c.borderSubtle);
    });

    test('dark', () {
      final scheme = WasliColorSchemes.dark;
      const c = WasliColors.dark;

      expect(scheme.brightness, Brightness.dark);
      expect(scheme.primary, c.primary);
      expect(scheme.surface, c.surface);
      expect(scheme.onSurface, c.text);
    });

    test('no Material surface role draws a tint of its own', () {
      for (final scheme in [WasliColorSchemes.light, WasliColorSchemes.dark]) {
        expect(scheme.surfaceTint.a, 0);
        expect(scheme.surfaceContainerLowest, scheme.surface);
        expect(scheme.surfaceContainerLow, scheme.surface);
        expect(scheme.surfaceContainer, scheme.surface);
        expect(scheme.surfaceContainerHigh, scheme.surface);
        expect(scheme.surfaceContainerHighest, scheme.surface);
      }
    });
  });
}
