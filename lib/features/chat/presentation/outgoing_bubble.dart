import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/features/chat/application/chat_state.dart';
import 'package:wasli_customer/features/chat/presentation/chat_bubble.dart';
import 'package:wasli_customer/theme/theme.dart';

/// A message of the customer that the server has not acknowledged: it shows at once, says "Sending…", and when sending
/// failed says "Not sent" with a "Retry" button that sends it again with the same message id.
class OutgoingBubble extends StatelessWidget {
  /// Creates the bubble for [message]; [onRetry] sends it again.
  const new({required this.message, required this.onRetry, super.key});

  /// The unacknowledged message.
  final OutgoingMessage message;

  /// Sends it again.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.wasli;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ChatBubble(
          fromCustomer: true,
          child: Opacity(
            opacity: message.failed ? 1 : 0.7,
            child: Text(message.label, style: context.wasliText.body),
          ),
        ),
        if (message.failed)
          Semantics(
            liveRegion: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: WasliSpacing.space4, color: colors.error),
                const SizedBox(width: WasliSpacing.space1),
                Text(l10n.chatNotSent, style: context.wasliText.caption.copyWith(color: colors.error)),
                TextButton(onPressed: onRetry, child: Text(l10n.chatRetry)),
              ],
            ),
          )
        else
          Text(l10n.chatSending, style: context.wasliText.caption.copyWith(color: colors.textMuted)),
      ],
    );
  }
}
