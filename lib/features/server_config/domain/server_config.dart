/// How an order's position is checked by the server.
enum LocationCheck {
  /// The position is not checked.
  off,

  /// The position is recorded and shown to the restaurant; it never blocks an order.
  warn,

  /// A position that is too far blocks the order.
  enforce,

  /// A rule this version of the app does not know; treated as "not checked" by the app.
  unknown,
}

/// The switches the server tells the app before anything else (`GET /config`).
///
/// Read once at start and kept for the session. The app never decides these things itself: it follows the server.
class ServerConfig {
  /// Creates the settings.
  const new({
    required this.locationCheck,
    required this.requireScreenOnline,
    required this.aiEnabled,
    required this.languages,
    required this.pollInterval,
  });

  /// How an order's position is checked.
  final LocationCheck locationCheck;

  /// Whether a restaurant is listed only while its screen is online.
  final bool requireScreenOnline;

  /// Whether the ordering assistant is available. `false` means the app offers the item picker.
  final bool aiEnabled;

  /// The language codes of the product (`en`, `ar`).
  final List<String> languages;

  /// How often the chat and the order are polled for news.
  final Duration pollInterval;
}
