import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/theme/theme.dart';

/// A small pill that says whether a contact was confirmed with a code: an icon and a word, never colour alone.
class VerifiedBadge extends StatelessWidget {
  /// Creates the badge; [verified] is whether the contact was confirmed.
  const new({required this.verified, super.key});

  /// Whether the contact was confirmed.
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.wasli;
    final background = verified ? colors.statusOkBackground : colors.statusWarnBackground;
    final foreground = verified ? colors.statusOkForeground : colors.statusWarnForeground;

    return DecoratedBox(
      decoration: BoxDecoration(color: background, borderRadius: WasliRadius.fullAll),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: WasliSpacing.space2, vertical: WasliSpacing.space1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              verified ? Icons.check_circle_outline : Icons.error_outline,
              size: WasliSpacing.space4,
              color: foreground,
            ),
            const SizedBox(width: WasliSpacing.space1),
            Text(
              verified ? l10n.accountVerified : l10n.accountNotVerified,
              style: context.wasliText.caption.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
