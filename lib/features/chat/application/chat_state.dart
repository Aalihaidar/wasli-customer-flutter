import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/features/chat/domain/chat_action.dart';
import 'package:wasli_customer/features/chat/domain/chat_message.dart';
import 'package:wasli_customer/features/chat/domain/conversation.dart';

/// Something the customer is told once, above the composer, until they dismiss it or act on it.
enum ChatNotice {
  /// The order was not sent because no phone number is confirmed yet. Nothing was stored; the customer confirms a phone
  /// and presses "Yes, send" again.
  phoneNotVerified,

  /// The conversation had expired, so the server started a new one. The customer's last message was not stored.
  conversationRestarted,
}

/// Where sharing the position for the order stands. It is asked at the car question and not earlier.
enum LocationSharing {
  /// Not asked yet: the explanation and its buttons show at the car question.
  notAsked,

  /// The permission prompt or the position or the upload is in progress.
  sharing,

  /// The restaurant has the position.
  shared,

  /// The customer refused, or no position could be read or sent. The restaurant decides without it.
  notShared,
}

/// A message of the customer that the server has not acknowledged yet: shown at once, then replaced by the server's own
/// message, or marked as failed with a way to retry.
class OutgoingMessage {
  /// Creates an outgoing message. Exactly one of [text] and [action] is set.
  const new({required this.clientMessageId, required this.label, this.text, this.action, this.failure});

  /// The id made once for this user action and reused for every retry, so the server stores the message once.
  final String clientMessageId;

  /// What the bubble shows: the typed text, or the label of the button that was tapped.
  final String label;

  /// The typed text, or `null` for a button.
  final String? text;

  /// The button's action, or `null` for typed text.
  final ChatAction? action;

  /// Why it was not sent, or `null` while it is being sent.
  final Failure? failure;

  /// Whether it could not be sent and waits for "Retry".
  bool get failed => failure != null;

  /// The same message, marked as failed with [failure], or as being sent again when [failure] is `null`.
  OutgoingMessage withFailure(Failure? failure) {
    return OutgoingMessage(
      clientMessageId: clientMessageId,
      label: label,
      text: text,
      action: action,
      failure: failure,
    );
  }
}

/// Everything the chat screen shows.
class ChatState {
  /// Creates the state.
  const new({
    required this.conversation,
    required this.messages,
    this.outgoing = const [],
    this.notice,
    this.locationSharing = LocationSharing.notAsked,
  });

  /// The conversation as the server last described it.
  final Conversation conversation;

  /// The server's messages, in `seq` order, without duplicates.
  final List<ChatMessage> messages;

  /// The customer's messages that are not acknowledged yet, oldest first.
  final List<OutgoingMessage> outgoing;

  /// A one-time notice, or `null`.
  final ChatNotice? notice;

  /// Where sharing the position stands.
  final LocationSharing locationSharing;

  /// The `seq` of the newest message, or 0 when there is none. The next poll asks for everything after it.
  int get lastSeq => messages.isEmpty ? 0 : messages.last.seq;

  /// A copy with the given parts replaced. [clearNotice] removes the notice.
  ChatState copyWith({
    Conversation? conversation,
    List<ChatMessage>? messages,
    List<OutgoingMessage>? outgoing,
    ChatNotice? notice,
    bool clearNotice = false,
    LocationSharing? locationSharing,
  }) {
    return ChatState(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      outgoing: outgoing ?? this.outgoing,
      notice: clearNotice ? null : (notice ?? this.notice),
      locationSharing: locationSharing ?? this.locationSharing,
    );
  }
}
