import 'package:wasli_customer/features/chat/domain/chat_message.dart';
import 'package:wasli_customer/features/chat/domain/conversation.dart';

/// What the server answers to opening, reading and writing: the conversation as it is now and some of its messages.
class ChatSnapshot {
  /// Creates a snapshot.
  const new({required this.conversation, required this.messages});

  /// The conversation now.
  final Conversation conversation;

  /// The messages the call returned, in `seq` order: the whole history when opening, the new ones otherwise.
  final List<ChatMessage> messages;
}
