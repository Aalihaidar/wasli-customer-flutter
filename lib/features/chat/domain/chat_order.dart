/// The order a conversation produced, once it is placed.
class ChatOrder {
  /// Creates the order reference.
  const new({required this.id, required this.number, required this.status});

  /// The order's id (a UUID).
  final String id;

  /// The number the customer and the restaurant quote.
  final int number;

  /// The status as the server writes it (`placed`, `accepted`, ...). It is an open set; the app does not decide it.
  final String status;
}
