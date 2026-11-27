import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/theme/theme.dart';

/// A card on the start page that talks about the customer's location: the explanation before the first request and the
/// reason when location is refused, off or unavailable. It always ends with the hint that a QR code works without
/// location.
class LocationNotice extends StatelessWidget {
  /// Creates the notice: [title] and [body] say what is going on and [actions] are the buttons under them.
  const new({required this.title, required this.body, required this.actions, super.key});

  /// The heading.
  final String title;

  /// The text under the heading.
  final String body;

  /// The buttons, in order; the first is the main one.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.wasli;

    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(WasliSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.location_on_outlined, size: WasliSpacing.space6, color: colors.primary),
            const SizedBox(height: WasliSpacing.space3),
            Semantics(header: true, child: Text(title, style: context.wasliText.heading2)),
            const SizedBox(height: WasliSpacing.space2),
            Text(body, style: context.wasliText.body),
            const SizedBox(height: WasliSpacing.space4),
            for (final (index, action) in actions.indexed) ...[
              if (index > 0) const SizedBox(height: WasliSpacing.space2),
              action,
            ],
            const SizedBox(height: WasliSpacing.space4),
            Text(
              context.l10n.startLocationQrHint,
              style: context.wasliText.bodySmall.copyWith(color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
