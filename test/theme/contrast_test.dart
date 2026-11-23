import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/theme/theme.dart';

import '../support/contrast.dart';

/// The accessibility rules of the design page: 4.5:1 for text and 3:1 for outlines, in both themes.
void main() {
  const textMinimum = 4.5;
  const outlineMinimum = 3.0;

  final themes = {'light': WasliColors.light, 'dark': WasliColors.dark};

  for (final MapEntry(key: name, value: c) in themes.entries) {
    group('$name theme', () {
      void expectText(String label, Color foreground, Color background) {
        test('$label has at least 4.5:1', () {
          expect(contrastRatio(foreground, background), greaterThanOrEqualTo(textMinimum));
        });
      }

      void expectOutline(String label, Color line, Color background) {
        test('$label has at least 3:1', () {
          expect(contrastRatio(line, background), greaterThanOrEqualTo(outlineMinimum));
        });
      }

      expectText('text on the page', c.text, c.background);
      expectText('text on a surface', c.text, c.surface);
      expectText('muted text on the page', c.textMuted, c.background);
      expectText('muted text on a surface', c.textMuted, c.surface);
      expectText('a link on the page', c.link, c.background);
      expectText('a link on a surface', c.link, c.surface);
      expectText('an error on the page', c.error, c.background);
      expectText('an error on a surface', c.error, c.surface);
      expectText('content on an error fill', c.onError, c.error);
      expectText('content on a primary button', c.onPrimary, c.primary);
      expectText('content on a pressed primary button', c.onPrimary, c.primaryDark);
      expectText('content on mustard', c.onAccent, c.accent);
      expectText('the placed pill', c.statusWarnForeground, c.statusWarnBackground);
      expectText('the accepted pill', c.statusInfoForeground, c.statusInfoBackground);
      expectText('the ready pill', c.statusOkForeground, c.statusOkBackground);
      expectText('the rejected pill', c.statusBadForeground, c.statusBadBackground);

      expectOutline('an input outline on the page', c.borderInput, c.background);
      expectOutline('an input outline on a surface', c.borderInput, c.surface);
      expectOutline('the focus ring on the page', c.focusRing, c.background);
      expectOutline('the focus ring on a surface', c.focusRing, c.surface);
    });
  }
}
