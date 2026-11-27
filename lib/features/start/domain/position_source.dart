/// Where the customer's position on the start screen comes from.
enum PositionSource {
  /// The device's own position.
  gps,

  /// A position chosen by the customer in a test build, for example "I'm at the restaurant". The server is told the
  /// position was simulated when it receives one (`source = simulated`).
  simulated,
}
