/// Where a conversation is, as the server says. The server decides every step; the app only shows it.
enum ChatStep {
  /// The customer is choosing what to order.
  ordering,

  /// The server asks for the parking place and the car.
  askCar,

  /// The server asks for an optional note.
  askNote,

  /// The server shows the whole order and asks for the final confirmation.
  review,

  /// The order was sent to the restaurant. The conversation takes no more input.
  placed,

  /// A step this version of the app does not know; it is treated like an open step and the server's text is shown.
  unknown,
}
