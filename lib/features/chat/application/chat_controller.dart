import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show AsyncNotifierProviderFamily;
import 'package:wasli_customer/core/error/api_error_code.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/l10n/locale_controller.dart';
import 'package:wasli_customer/core/platform/location/location_access.dart';
import 'package:wasli_customer/core/platform/location/location_providers.dart';
import 'package:wasli_customer/core/platform/location/location_unavailable_exception.dart';
import 'package:wasli_customer/core/polling/poller.dart';
import 'package:wasli_customer/core/time/clock.dart';
import 'package:wasli_customer/features/chat/application/chat_providers.dart';
import 'package:wasli_customer/features/chat/application/chat_state.dart';
import 'package:wasli_customer/features/chat/domain/chat_message.dart';
import 'package:wasli_customer/features/chat/domain/chat_snapshot.dart';
import 'package:wasli_customer/features/chat/domain/quick_reply.dart';
import 'package:wasli_customer/features/chat/domain/shared_position.dart';
import 'package:wasli_customer/features/server_config/application/server_config_providers.dart';

/// The longest text a customer may send, in code points, counted after trimming.
const int maxChatTextLength = 500;

/// How long after the last message arrived the chat stops asking the server for news. It starts again when the customer
/// comes back to the visible chat or sends something.
const Duration chatIdleTimeout = Duration(minutes: 10);

/// The conversation with one restaurant (by slug), read when its screen first asks and dropped when the screen closes.
///
/// A failed open is the provider's error and the screen offers "Try again" (`ref.invalidate`).
final AsyncNotifierProviderFamily<ChatController, ChatState, String> chatControllerProvider = AsyncNotifierProvider
    .autoDispose
    .family<ChatController, ChatState, String>(ChatController.new, retry: (retryCount, error) => null);

/// Opens the conversation, keeps it in step with the server and sends what the customer writes.
///
/// The server decides everything: this class shows its messages in `seq` order, sends the customer's text and buttons with
/// a message id that a retry reuses, and asks for news every `poll_interval_seconds` while the chat is visible and not
/// idle. It never writes bot text, never computes a price and never decides a step.
class ChatController extends AsyncNotifier<ChatState> {
  /// Creates the controller for the restaurant named [slug].
  new(this.slug);

  /// The restaurant's address name.
  final String slug;

  late final Poller _poller = Poller(interval: () => ref.read(pollIntervalProvider), onTick: _poll);
  DateTime _lastActivity = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  bool _sending = false;
  bool _visible = true;

  @override
  Future<ChatState> build() async {
    ref.onDispose(_poller.stop);
    final snapshot = await ref.read(chatRepositoryProvider).open(slug, languageCode: _languageCode);
    _lastActivity = ref.read(clockProvider)();
    _poller.start();
    return ChatState(conversation: snapshot.conversation, messages: snapshot.messages);
  }

  String get _languageCode => ref.read(localeProvider).languageCode;

  ChatState? get _current => state.value;

  /// Sends typed [text]: trimmed, not empty and at most [maxChatTextLength] code points, otherwise nothing happens.
  Future<void> sendText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.runes.length > maxChatTextLength) {
      return Future.value();
    }
    return _dispatch(OutgoingMessage(clientMessageId: ref.read(messageIdProvider)(), label: trimmed, text: trimmed));
  }

  /// Sends the button [reply]: its label shows as the customer's message and its action goes to the server as it is.
  Future<void> sendReply(QuickReply reply) {
    return _dispatch(
      OutgoingMessage(clientMessageId: ref.read(messageIdProvider)(), label: reply.label, action: reply.action),
    );
  }

  /// Sends a message that failed once more, with the same message id.
  Future<void> retry(String clientMessageId) {
    final failed = _current?.outgoing.where((message) => message.clientMessageId == clientMessageId).firstOrNull;
    return failed == null ? Future.value() : _dispatch(failed);
  }

  /// Starts a new conversation with the restaurant ("Order again").
  Future<void> orderAgain() => _reopen(startNew: true);

  /// Removes the notice.
  void dismissNotice() {
    final current = _current;
    if (current != null) {
      state = AsyncData(current.copyWith(clearNotice: true));
    }
  }

  /// Tells the chat whether its screen is visible. Hidden stops asking the server for news; visible asks at once and
  /// counts the idle time from now.
  void setVisible({required bool visible}) {
    _visible = visible;
    if (!visible) {
      _poller.stop();
    } else if (_current != null) {
      _lastActivity = ref.read(clockProvider)();
      _poller.start(immediately: true);
    }
  }

  /// Shares the device's position for the order (the customer pressed the button that explained why).
  Future<void> shareMyLocation() async {
    _setLocation(LocationSharing.sharing);
    final service = ref.read(locationServiceProvider);
    try {
      var access = await service.access();
      if (access == LocationAccess.askable) {
        access = await service.requestAccess();
      }
      if (access != LocationAccess.allowed) {
        _setLocation(LocationSharing.notShared);
        return;
      }
      final position = await service.currentPosition();
      await _sharePosition(
        SharedPosition(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracyMetres: position.accuracyMetres,
        ),
      );
    } on LocationUnavailableException {
      _setLocation(LocationSharing.notShared);
    } on Failure {
      _setLocation(LocationSharing.notShared);
    }
  }

  /// Shares a pretend position (a test build's "I'm at the restaurant").
  Future<void> shareSimulatedLocation({required double latitude, required double longitude}) async {
    _setLocation(LocationSharing.sharing);
    try {
      await _sharePosition(
        SharedPosition(latitude: latitude, longitude: longitude, accuracyMetres: 5, simulated: true),
      );
    } on Failure {
      _setLocation(LocationSharing.notShared);
    }
  }

  /// Keeps the customer's position from being asked again for this conversation ("Not now").
  void skipLocation() => _setLocation(LocationSharing.notShared);

  Future<void> _sharePosition(SharedPosition position) async {
    final current = _current;
    if (current == null) {
      return;
    }
    await ref.read(chatRepositoryProvider).shareLocation(current.conversation.id, position);
    _setLocation(LocationSharing.shared);
  }

  void _setLocation(LocationSharing sharing) {
    final current = _current;
    if (ref.mounted && current != null) {
      state = AsyncData(current.copyWith(locationSharing: sharing));
    }
  }

  Future<void> _poll() async {
    final current = _current;
    if (current == null || _sending) {
      return;
    }
    if (ref.read(clockProvider)().difference(_lastActivity) > chatIdleTimeout) {
      _poller.stop();
      return;
    }
    await _fetchNews();
  }

  Future<void> _fetchNews() async {
    final current = _current;
    if (current == null) {
      return;
    }
    final snapshot = await ref.read(chatRepositoryProvider).messagesAfter(current.conversation.id, current.lastSeq);
    if (ref.mounted) {
      _apply(snapshot);
    }
  }

  Future<void> _dispatch(OutgoingMessage message) async {
    final current = _current;
    if (current == null || _sending) {
      return;
    }
    _sending = true;
    _setOutgoing(current, [..._withoutMessage(current, message), message.withFailure(null)]);
    final repository = ref.read(chatRepositoryProvider);
    try {
      final conversationId = current.conversation.id;
      final text = message.text;
      final snapshot = text != null
          ? await repository.sendText(conversationId, clientMessageId: message.clientMessageId, text: text)
          : await repository.sendAction(
              conversationId,
              clientMessageId: message.clientMessageId,
              action: message.action!,
            );
      if (ref.mounted) {
        _apply(snapshot, acknowledged: message.clientMessageId);
        _lastActivity = ref.read(clockProvider)();
        if (_visible) {
          _poller.start();
        }
      }
    } on Failure catch (failure) {
      if (ref.mounted) {
        await _handleSendFailure(message, failure);
      }
    } finally {
      _sending = false;
    }
  }

  Future<void> _handleSendFailure(OutgoingMessage message, Failure failure) async {
    final current = _current;
    if (current == null) {
      return;
    }
    final without = _withoutMessage(current, message);
    switch (failure) {
      case ConflictFailure() when failure.has(ApiErrorCode.conversationExpired):
        // Nothing was stored. The server starts a new, empty conversation; the draft is not carried over.
        await _reopen();
      case PhoneNotVerifiedFailure():
        state = AsyncData(current.copyWith(outgoing: without, notice: ChatNotice.phoneNotVerified));
      case ConflictFailure() when failure.has(ApiErrorCode.invalidActionForState):
        // The button no longer applies: the screen was behind the server. Drop it and catch up.
        state = AsyncData(current.copyWith(outgoing: without));
        try {
          await _fetchNews();
        } on Failure {
          // The next poll tries again.
        }
      case _:
        _setOutgoing(current, [...without, message.withFailure(failure)]);
    }
  }

  Future<void> _reopen({bool startNew = false}) async {
    final current = _current;
    if (current == null) {
      return;
    }
    try {
      final snapshot = await ref
          .read(chatRepositoryProvider)
          .open(slug, languageCode: _languageCode, startNew: startNew);
      if (!ref.mounted) {
        return;
      }
      _lastActivity = ref.read(clockProvider)();
      state = AsyncData(
        ChatState(
          conversation: snapshot.conversation,
          messages: snapshot.messages,
          notice: startNew ? null : ChatNotice.conversationRestarted,
        ),
      );
      if (_visible) {
        _poller.start();
      }
    } on Failure {
      // Keep what is on screen; the customer can try again.
    }
  }

  List<OutgoingMessage> _withoutMessage(ChatState current, OutgoingMessage message) => [
    for (final other in current.outgoing)
      if (other.clientMessageId != message.clientMessageId) other,
  ];

  void _setOutgoing(ChatState current, List<OutgoingMessage> outgoing) {
    if (ref.mounted) {
      state = AsyncData(current.copyWith(outgoing: outgoing));
    }
  }

  /// Merges [snapshot] into the state by `seq`, drops the acknowledged outgoing message, and counts a new message as
  /// activity so the idle timer starts from it.
  void _apply(ChatSnapshot snapshot, {String? acknowledged}) {
    final current = _current;
    if (current == null) {
      return;
    }
    final bySeq = <int, ChatMessage>{for (final message in current.messages) message.seq: message};
    var added = false;
    for (final message in snapshot.messages) {
      added = added || !bySeq.containsKey(message.seq);
      bySeq[message.seq] = message;
    }
    if (added) {
      _lastActivity = ref.read(clockProvider)();
    }
    final messages = bySeq.values.toList()..sort((a, b) => a.seq.compareTo(b.seq));
    state = AsyncData(
      current.copyWith(
        conversation: snapshot.conversation,
        messages: messages,
        outgoing: [
          for (final message in current.outgoing)
            if (message.clientMessageId != acknowledged) message,
        ],
      ),
    );
  }
}
