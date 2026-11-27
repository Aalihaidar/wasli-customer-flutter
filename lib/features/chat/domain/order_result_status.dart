/// The restaurant's answer to an order, as a `result` message states it.
enum OrderResultStatus {
  /// The restaurant accepted it and gave a wait time.
  accepted,

  /// The restaurant rejected it.
  rejected,

  /// The restaurant says it is ready and on its way to the car.
  ready,

  /// A status this version of the app does not know; the server's text is shown on a plain card.
  unknown,
}
