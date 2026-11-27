import 'package:wasli_customer/api/api.dart';
import 'package:wasli_customer/features/chat/domain/chat_action.dart';
import 'package:wasli_customer/features/chat/domain/chat_message.dart';
import 'package:wasli_customer/features/chat/domain/chat_order.dart';
import 'package:wasli_customer/features/chat/domain/chat_snapshot.dart';
import 'package:wasli_customer/features/chat/domain/chat_step.dart';
import 'package:wasli_customer/features/chat/domain/conversation.dart';
import 'package:wasli_customer/features/chat/domain/order_result_status.dart';
import 'package:wasli_customer/features/chat/domain/order_summary.dart';
import 'package:wasli_customer/features/chat/domain/quick_reply.dart';

/// Turns the generated `Chat` answer into the app's [ChatSnapshot].
ChatSnapshot chatSnapshotFromDto(Chat$Response dto) {
  return ChatSnapshot(
    conversation: conversationFromDto(dto.conversation),
    messages: [for (final message in dto.messages) chatMessageFromDto(message)]..sort((a, b) => a.seq.compareTo(b.seq)),
  );
}

/// Turns the generated conversation into a [Conversation]. A step the app does not know becomes [ChatStep.unknown].
Conversation conversationFromDto(Conversation$Response dto) {
  final order = dto.order;
  return Conversation(
    id: dto.id,
    restaurantSlug: dto.restaurantSlug,
    step: switch (dto.state.value) {
      'ordering' => ChatStep.ordering,
      'ask_car' => ChatStep.askCar,
      'ask_note' => ChatStep.askNote,
      'review' => ChatStep.review,
      'placed' => ChatStep.placed,
      _ => ChatStep.unknown,
    },
    languageCode: dto.locale.value,
    aiAvailable: dto.aiAvailable,
    expiresAt: dto.expiresAt,
    order: order == null ? null : ChatOrder(id: order.id, number: order.number, status: order.status.value),
  );
}

/// Turns a generated message into a [ChatMessage]. The `payload` is open on purpose: the keys the app knows are read one
/// by one and anything else is ignored, and a kind the app does not know is shown as a plain text message.
ChatMessage chatMessageFromDto(Message$Response dto) {
  final payload = _asMap(dto.payload);
  final replies = _quickReplies(payload['quick_replies']);
  final fromCustomer = dto.sender.value == 'customer';

  return switch (dto.kind.value) {
    'image' => ImageMessage(
      id: dto.id,
      seq: dto.seq,
      fromCustomer: fromCustomer,
      createdAt: dto.createdAt,
      text: dto.text,
      imageUrl: dto.imageUrl,
    ),
    'order_summary' => OrderSummaryMessage(
      id: dto.id,
      seq: dto.seq,
      fromCustomer: fromCustomer,
      createdAt: dto.createdAt,
      text: dto.text,
      summary: _summary(payload['summary']),
      quickReplies: replies,
    ),
    'review' => ReviewMessage(
      id: dto.id,
      seq: dto.seq,
      fromCustomer: fromCustomer,
      createdAt: dto.createdAt,
      text: dto.text,
      summary: _summary(payload['summary']),
      parkingNote: _string(payload['parking_note']),
      vehiclePlate: _string(payload['vehicle_plate']),
      vehicleModel: _string(payload['vehicle_model']),
      vehicleColour: _string(payload['vehicle_colour']),
      orderNote: _string(payload['order_note']),
      locationShared: payload['location_shared'] == true,
      quickReplies: replies,
    ),
    'result' => ResultMessage(
      id: dto.id,
      seq: dto.seq,
      fromCustomer: fromCustomer,
      createdAt: dto.createdAt,
      text: dto.text,
      status: switch (payload['status']) {
        'accepted' => OrderResultStatus.accepted,
        'rejected' => OrderResultStatus.rejected,
        'ready' => OrderResultStatus.ready,
        _ => OrderResultStatus.unknown,
      },
      orderNumber: _int(payload['number']),
      etaMinutes: _int(payload['eta_minutes']),
      rejectionNote: _stringOrNull(payload['rejection_note']),
    ),
    _ => TextMessage(
      id: dto.id,
      seq: dto.seq,
      fromCustomer: fromCustomer,
      createdAt: dto.createdAt,
      text: dto.text,
      quickReplies: replies,
      transcript: dto.usedVoice ? _stringOrNull(dto.transcript) : null,
    ),
  };
}

/// The generated request for a button's [action].
SendMessageRequest sendActionRequest(String clientMessageId, ChatAction action) {
  return switch (action) {
    ConfirmAction() => SendMessageRequest(clientMessageId: clientMessageId, action: ActionEnum.confirm),
    EditAction() => SendMessageRequest(clientMessageId: clientMessageId, action: ActionEnum.edit),
    EditFieldAction(:final field) => SendMessageRequest(
      clientMessageId: clientMessageId,
      action: ActionEnum.editField,
      field: switch (field) {
        ChatField.items => FieldEnum.items,
        ChatField.car => FieldEnum.car,
        ChatField.note => FieldEnum.note,
      },
    ),
    ChooseAction(:final value) => SendMessageRequest(
      clientMessageId: clientMessageId,
      action: ActionEnum.choose,
      value: value,
    ),
    SkipNoteAction() => SendMessageRequest(clientMessageId: clientMessageId, action: ActionEnum.skipNote),
    RestartAction() => SendMessageRequest(clientMessageId: clientMessageId, action: ActionEnum.restart),
  };
}

List<QuickReply> _quickReplies(Object? raw) {
  if (raw is! List<Object?>) {
    return const [];
  }
  return [for (final item in raw) ?_quickReply(_asMap(item))];
}

// A quick reply whose action the app cannot send is left out: a button that does nothing helps nobody.
QuickReply? _quickReply(Map<String, Object?> json) {
  final label = _stringOrNull(json['label']);
  final action = switch (json['action']) {
    'confirm' => const ConfirmAction(),
    'edit' => const EditAction(),
    'skip_note' => const SkipNoteAction(),
    'restart' => const RestartAction(),
    'choose' => switch (_stringOrNull(json['value'])) {
      final value? => ChooseAction(value),
      null => null,
    },
    'edit_field' => switch (json['field']) {
      'items' => const EditFieldAction(ChatField.items),
      'car' => const EditFieldAction(ChatField.car),
      'note' => const EditFieldAction(ChatField.note),
      _ => null,
    },
    _ => null,
  };
  return label == null || action == null ? null : QuickReply(label: label, action: action);
}

OrderSummary? _summary(Object? raw) {
  final json = _asMap(raw);
  if (json.isEmpty) {
    return null;
  }
  final lines = json['lines'];
  return OrderSummary(
    lines: [
      if (lines is List<Object?>)
        for (final line in lines) _line(_asMap(line)),
    ],
    subtotalMinor: _int(json['subtotal_minor']) ?? 0,
    totalMinor: _int(json['total_minor']) ?? 0,
    currency: _stringOrNull(json['currency']) ?? 'AED',
  );
}

SummaryLine _line(Map<String, Object?> json) {
  final options = json['options'];
  return SummaryLine(
    name: _string(json['name']),
    optionNames: [
      if (options is List<Object?>)
        for (final option in options) ?_stringOrNull(_asMap(option)['name']),
    ],
    quantity: _int(json['quantity']) ?? 1,
    note: _stringOrNull(json['note']),
    lineTotalMinor: _int(json['line_total_minor']) ?? 0,
  );
}

Map<String, Object?> _asMap(Object? value) => value is Map<String, Object?> ? value : const {};

String _string(Object? value) => value is String ? value : '';

String? _stringOrNull(Object? value) => value is String && value.isNotEmpty ? value : null;

int? _int(Object? value) => value is int ? value : null;
