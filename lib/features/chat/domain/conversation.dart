import 'package:wasli_customer/features/chat/domain/chat_order.dart';
import 'package:wasli_customer/features/chat/domain/chat_step.dart';

/// The conversation with one restaurant.
class Conversation {
  /// Creates a conversation.
  const new({
    required this.id,
    required this.restaurantSlug,
    required this.step,
    required this.languageCode,
    required this.aiAvailable,
    required this.expiresAt,
    this.order,
  });

  /// The conversation's id (a UUID).
  final String id;

  /// The restaurant's address name.
  final String restaurantSlug;

  /// Where the conversation is.
  final ChatStep step;

  /// The language the server writes in (`en` or `ar`).
  final String languageCode;

  /// Whether the ordering assistant is available. When it is not, the server still takes buttons and asks one thing at
  /// a time.
  final bool aiAvailable;

  /// When the conversation closes if the customer writes nothing more (UTC).
  final DateTime expiresAt;

  /// The order, once it is placed; `null` before.
  final ChatOrder? order;
}
