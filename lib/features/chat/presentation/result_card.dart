import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/features/chat/domain/chat_message.dart';
import 'package:wasli_customer/features/chat/domain/order_result_status.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The restaurant's answer to the order, as a full-width banner in the status colour: green for accepted and ready, red for
/// rejected, plain for a status this version does not know. The sentence is the server's, shown as it is. The icon and
/// the word say the same as the colour.
class ResultCard extends StatelessWidget {
  /// Creates the card for [message].
  const new({required this.message, super.key});

  /// The message to show.
  final ResultMessage message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.wasli;
    final status = message.status;
    final (background, foreground, icon, title) = switch (status) {
      OrderResultStatus.accepted => (
        colors.statusOkBackground,
        colors.statusOkForeground,
        Icons.check_circle_outline,
        l10n.chatResultAccepted,
      ),
      OrderResultStatus.ready => (
        colors.statusOkBackground,
        colors.statusOkForeground,
        Icons.check_circle_outline,
        l10n.chatResultReady,
      ),
      OrderResultStatus.rejected => (
        colors.statusBadBackground,
        colors.statusBadForeground,
        Icons.cancel_outlined,
        l10n.chatResultRejected,
      ),
      OrderResultStatus.unknown => (colors.surface, colors.text, Icons.info_outline, l10n.chatResultUpdate),
    };
    final number = message.orderNumber;
    final eta = message.etaMinutes;
    final note = message.rejectionNote;

    return Semantics(
      liveRegion: true,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: WasliRadius.mdAll,
          border: status == OrderResultStatus.unknown ? Border.all(color: colors.borderSubtle) : null,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(WasliSpacing.space4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: foreground),
              const SizedBox(width: WasliSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      number == null ? title : '$title · ${l10n.chatResultOrder(number: number.toString())}',
                      style: context.wasliText.heading3.copyWith(color: foreground),
                    ),
                    if (status == OrderResultStatus.accepted && eta != null)
                      Text(
                        l10n.chatResultEta(minutes: eta.toString()),
                        style: context.wasliText.bodyStrong.copyWith(color: foreground),
                      ),
                    if (message.text.isNotEmpty)
                      Text(message.text, style: context.wasliText.body.copyWith(color: foreground)),
                    if (note != null) Text(note, style: context.wasliText.body.copyWith(color: foreground)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
