import 'package:wasli_customer/features/chat/domain/chat_action.dart';
import 'package:wasli_customer/features/chat/domain/chat_message.dart';
import 'package:wasli_customer/features/chat/domain/chat_order.dart';
import 'package:wasli_customer/features/chat/domain/chat_repository.dart';
import 'package:wasli_customer/features/chat/domain/chat_snapshot.dart';
import 'package:wasli_customer/features/chat/domain/chat_step.dart';
import 'package:wasli_customer/features/chat/domain/conversation.dart';
import 'package:wasli_customer/features/chat/domain/order_result_status.dart';
import 'package:wasli_customer/features/chat/domain/order_summary.dart';
import 'package:wasli_customer/features/chat/domain/quick_reply.dart';
import 'package:wasli_customer/features/chat/domain/shared_position.dart';

final DateTime _at = DateTime.utc(2026, 11, 27, 9);

/// A conversation with invented values.
Conversation demoConversation({
  ChatStep step = ChatStep.ordering,
  bool aiAvailable = true,
  String languageCode = 'en',
  ChatOrder? order,
}) {
  return Conversation(
    id: 'conv-1',
    restaurantSlug: 'demo-cafe',
    step: step,
    languageCode: languageCode,
    aiAvailable: aiAvailable,
    expiresAt: _at.add(const Duration(hours: 1)),
    order: order,
  );
}

/// A message of the server.
TextMessage botText(int seq, String text, {List<QuickReply> replies = const []}) =>
    TextMessage(id: 'm-$seq', seq: seq, fromCustomer: false, createdAt: _at, text: text, quickReplies: replies);

/// A message of the customer.
TextMessage customerText(int seq, String text) =>
    TextMessage(id: 'm-$seq', seq: seq, fromCustomer: true, createdAt: _at, text: text);

/// A button.
QuickReply reply(String label, [ChatAction action = const ConfirmAction()]) => QuickReply(label: label, action: action);

/// A priced order of one line.
const demoSummary = OrderSummary(
  lines: [
    SummaryLine(name: 'Latte', optionNames: ['Large'], quantity: 2, note: null, lineTotalMinor: 2900),
  ],
  subtotalMinor: 2900,
  totalMinor: 2900,
  currency: 'AED',
);

/// A result message of the restaurant.
ResultMessage botResult(int seq, OrderResultStatus status, String text, {int? eta, String? note}) => ResultMessage(
  id: 'm-$seq',
  seq: seq,
  fromCustomer: false,
  createdAt: _at,
  text: text,
  status: status,
  orderNumber: 17,
  etaMinutes: eta,
  rejectionNote: note,
);

/// A [ChatRepository] for tests. It keeps the conversation's messages like the server does; each call can be replaced:
/// [onOpen], [onSendText], [onSendAction], [onMessagesAfter] and [onShareLocation]. Every call is recorded in [calls].
class FakeChatRepository implements ChatRepository {
  /// Creates a repository holding [messages] (the welcome by default).
  new({Conversation? conversation, List<ChatMessage>? messages})
    : conversation = conversation ?? demoConversation(),
      messages = messages ?? [botText(1, 'Welcome to Demo Cafe.'), botText(2, 'What would you like to order?')];

  /// The conversation as the "server" holds it.
  Conversation conversation;

  /// The messages the "server" holds.
  List<ChatMessage> messages;

  /// Replaces opening.
  Future<ChatSnapshot> Function(bool startNew)? onOpen;

  /// Replaces sending text.
  Future<ChatSnapshot> Function(String clientMessageId, String text)? onSendText;

  /// Replaces sending a button.
  Future<ChatSnapshot> Function(String clientMessageId, ChatAction action)? onSendAction;

  /// Replaces reading news.
  Future<ChatSnapshot> Function(int afterSeq)? onMessagesAfter;

  /// Replaces sharing the position.
  Future<void> Function(SharedPosition position)? onShareLocation;

  /// What was called, in order, for example `open(false)`, `messagesAfter(2)`, `text(id-1: two lattes)`.
  final List<String> calls = [];

  /// The ids of the messages sent so far (typed and tapped), in order.
  final List<String> sentIds = [];

  /// The positions shared so far.
  final List<SharedPosition> positions = [];

  /// The message ids already stored, so a replay returns the first result (the server's idempotency).
  final Map<String, ChatSnapshot> _stored = {};

  /// Adds messages as the server would (the customer's own then the bot's) and returns them as a snapshot.
  ChatSnapshot append(List<ChatMessage> added) {
    messages = [...messages, ...added];
    return ChatSnapshot(conversation: conversation, messages: added);
  }

  /// The next free `seq`.
  int get nextSeq => messages.isEmpty ? 1 : messages.last.seq + 1;

  @override
  Future<ChatSnapshot> open(String slug, {required String languageCode, bool startNew = false}) {
    calls.add('open($startNew,$languageCode)');
    return onOpen?.call(startNew) ?? Future.value(ChatSnapshot(conversation: conversation, messages: messages));
  }

  @override
  Future<ChatSnapshot> messagesAfter(String conversationId, int afterSeq) {
    calls.add('messagesAfter($afterSeq)');
    return onMessagesAfter?.call(afterSeq) ??
        Future.value(
          ChatSnapshot(
            conversation: conversation,
            messages: [
              for (final m in messages)
                if (m.seq > afterSeq) m,
            ],
          ),
        );
  }

  @override
  Future<ChatSnapshot> sendText(String conversationId, {required String clientMessageId, required String text}) {
    calls.add('text($clientMessageId: $text)');
    sentIds.add(clientMessageId);
    final custom = onSendText;
    if (custom != null) {
      return custom(clientMessageId, text);
    }
    return Future.value(
      _stored.putIfAbsent(
        clientMessageId,
        () => append([customerText(nextSeq, text), botText(nextSeq + 1, 'Got it: $text')]),
      ),
    );
  }

  @override
  Future<ChatSnapshot> sendAction(
    String conversationId, {
    required String clientMessageId,
    required ChatAction action,
  }) {
    calls.add('action(${action.runtimeType})');
    sentIds.add(clientMessageId);
    final custom = onSendAction;
    if (custom != null) {
      return custom(clientMessageId, action);
    }
    return Future.value(
      _stored.putIfAbsent(
        clientMessageId,
        () => append([customerText(nextSeq, 'button'), botText(nextSeq + 1, 'Done')]),
      ),
    );
  }

  @override
  Future<void> shareLocation(String conversationId, SharedPosition position) {
    calls.add('location(${position.simulated ? 'simulated' : 'gps'})');
    positions.add(position);
    return onShareLocation?.call(position) ?? Future.value();
  }
}
