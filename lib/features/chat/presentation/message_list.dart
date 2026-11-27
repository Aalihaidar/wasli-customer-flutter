import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/features/chat/application/chat_state.dart';
import 'package:wasli_customer/features/chat/domain/chat_message.dart';
import 'package:wasli_customer/features/chat/presentation/image_bubble.dart';
import 'package:wasli_customer/features/chat/presentation/outgoing_bubble.dart';
import 'package:wasli_customer/features/chat/presentation/result_card.dart';
import 'package:wasli_customer/features/chat/presentation/summary_card.dart';
import 'package:wasli_customer/features/chat/presentation/text_bubble.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The conversation, oldest at the top and newest at the bottom, with the customer's unacknowledged messages after the
/// server's. The list starts at the bottom, so a new message is in view without any scrolling code. Built lazily, with a
/// stable key for every message.
class MessageList extends StatelessWidget {
  /// Creates the list. [onRetry] is called with the message id of a failed message.
  const new({required this.state, required this.onRetry, super.key});

  /// What to show.
  final ChatState state;

  /// Sends a failed message again.
  final ValueChanged<String> onRetry;

  @override
  Widget build(BuildContext context) {
    final server = state.messages;
    final outgoing = state.outgoing;
    final count = server.length + outgoing.length;

    return ListView.separated(
      reverse: true,
      padding: const EdgeInsetsDirectional.symmetric(vertical: WasliSpacing.space3),
      itemCount: count,
      separatorBuilder: (context, index) => const SizedBox(height: WasliSpacing.space2),
      itemBuilder: (context, index) {
        // The list is reversed: index 0 is the newest.
        final position = count - 1 - index;
        if (position >= server.length) {
          final message = outgoing[position - server.length];
          return OutgoingBubble(
            key: ValueKey(message.clientMessageId),
            message: message,
            onRetry: () => onRetry(message.clientMessageId),
          );
        }
        final message = server[position];
        return KeyedSubtree(
          key: ValueKey(message.id),
          child: switch (message) {
            final TextMessage text => TextBubble(message: text),
            final ImageMessage image => ImageBubble(message: image),
            final OrderSummaryMessage summary => SummaryCard(message: summary),
            final ReviewMessage review => ReviewCard(message: review),
            final ResultMessage result => ResultCard(message: result),
          },
        );
      },
    );
  }
}
