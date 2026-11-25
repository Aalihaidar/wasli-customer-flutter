/// Whether a customer is signed in on this device.
///
/// A sealed type with exactly two cases, so a screen handles both with an exhaustive `switch`. Who the customer is
/// (name, contacts) is not part of it: the account feature reads that from the server.
sealed class SessionState {
  const new();
}

/// Nobody is signed in: no token is stored.
final class SignedOut extends SessionState {
  /// Creates the state.
  const new();
}

/// A customer is signed in: a token is stored and the server has not refused it.
final class SignedIn extends SessionState {
  /// Creates the state.
  const new();
}
