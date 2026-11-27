import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/theme/theme.dart';

/// Placeholder rows shown while the list of restaurants loads, so the page keeps its shape. Static, so nothing animates
/// for a customer who asked for less motion.
class RestaurantPlaceholders extends StatelessWidget {
  /// Creates the placeholders.
  const new({super.key});

  static const int _rows = 3;

  @override
  Widget build(BuildContext context) {
    final colors = context.wasli;

    return Semantics(
      container: true,
      label: context.l10n.startLoadingRestaurants,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Column(
          children: [
            for (var i = 0; i < _rows; i++)
              Card(
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(WasliSpacing.space4),
                  child: Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(color: colors.borderSubtle, borderRadius: WasliRadius.smAll),
                        child: const SizedBox.square(dimension: WasliSpacing.space7),
                      ),
                      const SizedBox(width: WasliSpacing.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Bar(color: colors.borderSubtle, width: WasliSpacing.space8 * 2),
                            const SizedBox(height: WasliSpacing.space2),
                            _Bar(color: colors.borderSubtle, width: WasliSpacing.space8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const new({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: WasliRadius.smAll),
      child: SizedBox(width: width, height: WasliSpacing.space3),
    );
  }
}
