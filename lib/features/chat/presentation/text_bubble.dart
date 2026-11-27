import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/features/chat/domain/chat_message.dart';
import 'package:wasli_customer/features/chat/presentation/chat_bubble.dart';
import 'package:wasli_customer/theme/theme.dart';

/// A text message of the server or the customer. The text is the server's, shown as it is.
class TextBubble extends StatelessWidget {
  /// Creates the bubble for [message].
  const new({required this.message, super.key});

  /// The message to show.
  final TextMessage message;

  @override
  Widget build(BuildContext context) {
    return ChatBubble(
      fromCustomer: message.fromCustomer,
      child: Text(message.text, style: context.wasliText.body),
    );
  }
}
