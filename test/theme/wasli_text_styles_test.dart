import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/theme/theme.dart';

void main() {
  final english = WasliTextStyles.forLanguage('en');
  final arabic = WasliTextStyles.forLanguage('ar');

  void expectStyle(TextStyle style, {required double size, required double lineHeight, required FontWeight weight}) {
    expect(style.fontFamily, 'Rubik');
    expect(style.fontSize, size);
    expect(style.height! * style.fontSize!, closeTo(lineHeight, 1e-9));
    expect(style.fontWeight, weight);
    expect(style.fontVariations, [FontVariation.weight(weight.value.toDouble())]);
  }

  group('the type scale of the design', () {
    test('sizes, line heights and weights', () {
      expectStyle(english.display, size: 32, lineHeight: 40, weight: FontWeight.w700);
      expectStyle(english.heading1, size: 24, lineHeight: 32, weight: FontWeight.w700);
      expectStyle(english.heading2, size: 20, lineHeight: 28, weight: FontWeight.w600);
      expectStyle(english.heading3, size: 17, lineHeight: 24, weight: FontWeight.w600);
      expectStyle(english.body, size: 16, lineHeight: 24, weight: FontWeight.w400);
      expectStyle(english.bodyStrong, size: 16, lineHeight: 24, weight: FontWeight.w500);
      expectStyle(english.bodySmall, size: 14, lineHeight: 20, weight: FontWeight.w400);
      expectStyle(english.label, size: 14, lineHeight: 20, weight: FontWeight.w500);
      expectStyle(english.button, size: 16, lineHeight: 20, weight: FontWeight.w600);
      expectStyle(english.caption, size: 12, lineHeight: 16, weight: FontWeight.w400);
    });

    test('only the four design weights are used', () {
      final styles = [
        english.display,
        english.heading1,
        english.heading2,
        english.heading3,
        english.body,
        english.bodyStrong,
        english.bodySmall,
        english.label,
        english.button,
        english.caption,
      ];

      expect(styles.map((style) => style.fontWeight).toSet(), {
        FontWeight.w400,
        FontWeight.w500,
        FontWeight.w600,
        FontWeight.w700,
      });
    });
  });

  group('letter spacing', () {
    test('Latin display and heading_1 use -0.01 em', () {
      expect(english.display.letterSpacing, closeTo(-0.32, 1e-9));
      expect(english.heading1.letterSpacing, closeTo(-0.24, 1e-9));
    });

    test('every other Latin style has none', () {
      for (final style in [
        english.heading2,
        english.heading3,
        english.body,
        english.bodyStrong,
        english.bodySmall,
        english.label,
        english.button,
        english.caption,
      ]) {
        expect(style.letterSpacing, 0);
      }
    });

    test('Arabic never has any', () {
      for (final style in [arabic.display, arabic.heading1, arabic.heading2, arabic.body, arabic.caption]) {
        expect(style.letterSpacing, 0);
      }
    });

    test('an unknown language counts as Latin', () {
      expect(WasliTextStyles.forLanguage('fr').display.letterSpacing, english.display.letterSpacing);
    });
  });

  group('the Material text theme', () {
    final textTheme = english.toTextTheme();

    test('maps each slot to its design style', () {
      expect(textTheme.displaySmall, english.display);
      expect(textTheme.headlineSmall, english.heading1);
      expect(textTheme.titleLarge, english.heading2);
      expect(textTheme.titleMedium, english.heading3);
      expect(textTheme.bodyLarge, english.body);
      expect(textTheme.bodyMedium, english.body);
      expect(textTheme.bodySmall, english.bodySmall);
      expect(textTheme.labelLarge, english.button);
      expect(textTheme.labelMedium, english.label);
      expect(textTheme.labelSmall, english.caption);
    });
  });

  group('as a theme extension', () {
    test('withColor sets the colour on every style and keeps the rest', () {
      const color = Color(0xFF123456);
      final coloured = english.withColor(color);

      expect(coloured.body.color, color);
      expect(coloured.caption.color, color);
      expect(coloured.display.fontSize, english.display.fontSize);
    });

    test('copyWith replaces only the given style', () {
      const replacement = TextStyle(fontSize: 99);
      final copy = english.copyWith(caption: replacement);

      expect(copy.caption, replacement);
      expect(copy.body, english.body);
    });

    test('lerp at the ends returns each side, and a null other returns this', () {
      final big = english.copyWith(body: english.body.copyWith(fontSize: 32));

      expect(english.lerp(big, 0).body.fontSize, 16);
      expect(english.lerp(big, 1).body.fontSize, 32);
      expect(english.lerp(big, 0.5).body.fontSize, 24);
      expect(english.lerp(null, 0.5), same(english));
    });
  });
}
