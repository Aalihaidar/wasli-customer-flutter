import 'package:wasli_customer/features/chat/domain/chat_action.dart';
import 'package:wasli_customer/features/chat/domain/chat_snapshot.dart';
import 'package:wasli_customer/features/chat/domain/shared_position.dart';

/// Everything the app does with a conversation on the server. Needs a signed-in customer.
///
/// Every method throws a `Failure` when the call does not succeed (`core/error`). A reply that the customer can fix by
/// answering is not a failure: the server asks again inside the conversation.
abstract interface class ChatRepository {
  /// Opens the customer's conversation with the restaurant [slug]: the current one (placed, or not yet expired), or a
  /// new one with the welcome. With [startNew] it is always a new one ("Order again"). The server writes in [languageCode].
  Future<ChatSnapshot> open(String slug, {required String languageCode, bool startNew = false});

  /// The messages after [afterSeq] and the conversation as it is now. Reading still works after the conversation expired.
  Future<ChatSnapshot> messagesAfter(String conversationId, int afterSeq);

  /// Sends typed [text]. [clientMessageId] is made once per user action and reused to retry it: the server then returns
  /// the first result instead of storing the message twice.
  Future<ChatSnapshot> sendText(String conversationId, {required String clientMessageId, required String text});

  /// Sends a button's [action], with the same retry rule as [sendText].
  Future<ChatSnapshot> sendAction(String conversationId, {required String clientMessageId, required ChatAction action});

  /// Gives the restaurant the customer's [position] for the order. The latest one wins.
  Future<void> shareLocation(String conversationId, SharedPosition position);
}
