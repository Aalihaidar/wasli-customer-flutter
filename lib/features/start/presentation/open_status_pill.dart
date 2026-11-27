import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/theme/theme.dart';

/// A small pill that says whether a restaurant can take an order now: an icon and a word, never colour alone.
class OpenStatusPill extends StatelessWidget {
  /// Creates the pill; [isOpen] is whether the restaurant can take an order now.
  const new({required this.isOpen, super.key});

  /// Whether the restaurant can take an order now.
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.wasli;
    final background = isOpen ? colors.statusOkBackground : colors.surface;
    final foreground = isOpen ? colors.statusOkForeground : colors.textMuted;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: WasliRadius.fullAll,
        border: isOpen ? null : Border.all(color: colors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: WasliSpacing.space2, vertical: WasliSpacing.space1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOpen ? Icons.check_circle_outline : Icons.remove_circle_outline,
              size: WasliSpacing.space4,
              color: foreground,
            ),
            const SizedBox(width: WasliSpacing.space1),
            Text(
              isOpen ? l10n.startRestaurantOpen : l10n.startRestaurantClosed,
              style: context.wasliText.caption.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
