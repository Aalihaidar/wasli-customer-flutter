/// How long a request may take before the app gives up on it.
abstract final class NetworkTimeouts {
  /// Opening the connection.
  static const connect = Duration(seconds: 15);

  /// Sending the request (a voice clip is the largest body).
  static const send = Duration(seconds: 30);

  /// Waiting for the answer.
  static const receive = Duration(seconds: 30);

  /// Waiting for the answer to the first call of a visit.
  ///
  /// The staging server runs on a free host that sleeps when idle, and the first request can take up to a minute while
  /// it wakes up. The call that starts the app (`GET /config`) uses this longer limit, so a sleeping server is a wait
  /// and not an error.
  static const coldStart = Duration(seconds: 70);
}
