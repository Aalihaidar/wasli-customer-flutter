import 'package:material_ui/material_ui.dart';

/// The WCAG 2.x contrast ratio between two opaque colours, from 1 (identical) to 21 (black on white).
double contrastRatio(Color a, Color b) {
  final lighter = a.computeLuminance() > b.computeLuminance() ? a : b;
  final darker = identical(lighter, a) ? b : a;
  return (lighter.computeLuminance() + 0.05) / (darker.computeLuminance() + 0.05);
}
