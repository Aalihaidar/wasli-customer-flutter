import 'package:wasli_customer/features/chat/domain/order_result_status.dart';
import 'package:wasli_customer/features/chat/domain/order_summary.dart';
import 'package:wasli_customer/features/chat/domain/quick_reply.dart';

/// One message of a conversation. Messages are appended in `seq` order and never edited. The text is written by the
/// server in the conversation's language: the app shows it and never builds message text itself.
sealed class ChatMessage {
  /// Creates a message.
  const new({
    required this.id,
    required this.seq,
    required this.fromCustomer,
    required this.createdAt,
    required this.text,
  });

  /// The message's id (a UUID).
  final String id;

  /// The position in the conversation; grows with every message.
  final int seq;

  /// Whether the customer wrote it (typed, spoken or tapped), as opposed to the server.
  final bool fromCustomer;

  /// When the server stored it (UTC).
  final DateTime createdAt;

  /// The text, in the conversation's language.
  final String text;
}

/// A plain text message. It is also what a kind this version does not know is shown as.
final class TextMessage extends ChatMessage {
  /// Creates a text message.
  const new({
    required super.id,
    required super.seq,
    required super.fromCustomer,
    required super.createdAt,
    required super.text,
    this.quickReplies = const [],
    this.transcript,
  });

  /// The buttons under it (only the latest message's are active).
  final List<QuickReply> quickReplies;

  /// What the server heard, for a spoken message, or `null`.
  final String? transcript;
}

/// A picture the restaurant sends (a menu page) with its caption in [text].
final class ImageMessage extends ChatMessage {
  /// Creates an image message.
  const new({
    required super.id,
    required super.seq,
    required super.fromCustomer,
    required super.createdAt,
    required super.text,
    required this.imageUrl,
  });

  /// The absolute address of the picture, or `null` when there is none.
  final String? imageUrl;
}

/// The order so far, priced by the server, with the buttons that confirm or change it.
final class OrderSummaryMessage extends ChatMessage {
  /// Creates an order summary message.
  const new({
    required super.id,
    required super.seq,
    required super.fromCustomer,
    required super.createdAt,
    required super.text,
    required this.summary,
    this.quickReplies = const [],
  });

  /// The priced order, or `null` when the message did not carry one this version could read.
  final OrderSummary? summary;

  /// The buttons under it.
  final List<QuickReply> quickReplies;
}

/// The whole order with the car, the note and the position, before the final confirmation.
final class ReviewMessage extends ChatMessage {
  /// Creates a review message.
  const new({
    required super.id,
    required super.seq,
    required super.fromCustomer,
    required super.createdAt,
    required super.text,
    required this.summary,
    required this.parkingNote,
    required this.vehiclePlate,
    required this.vehicleModel,
    required this.vehicleColour,
    required this.orderNote,
    required this.locationShared,
    this.quickReplies = const [],
  });

  /// The priced order, or `null`.
  final OrderSummary? summary;

  /// Where the car is parked.
  final String parkingNote;

  /// The car's plate.
  final String vehiclePlate;

  /// The car's model.
  final String vehicleModel;

  /// The car's colour.
  final String vehicleColour;

  /// The note for the restaurant; empty when there is none.
  final String orderNote;

  /// Whether the customer's position was sent. The position itself is never part of a message.
  final bool locationShared;

  /// The buttons under it.
  final List<QuickReply> quickReplies;
}

/// The restaurant's answer to the order (accepted, rejected, ready). [text] is the sentence to show.
final class ResultMessage extends ChatMessage {
  /// Creates a result message.
  const new({
    required super.id,
    required super.seq,
    required super.fromCustomer,
    required super.createdAt,
    required super.text,
    required this.status,
    required this.orderNumber,
    this.etaMinutes,
    this.rejectionNote,
  });

  /// What the restaurant answered.
  final OrderResultStatus status;

  /// The order's number, or `null` when the message did not say.
  final int? orderNumber;

  /// The wait time the restaurant gave, only when it accepted.
  final int? etaMinutes;

  /// The restaurant's note, only when it rejected and wrote one.
  final String? rejectionNote;
}
