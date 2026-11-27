import 'package:wasli_customer/features/chat/domain/chat_action.dart';

/// A button under the latest message of the server. The label is already in the conversation's language.
class QuickReply {
  /// Creates a quick reply.
  const new({required this.label, required this.action});

  /// The text on the button, and the text of the customer's message when it is tapped.
  final String label;

  /// What it does.
  final ChatAction action;
}
