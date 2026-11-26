/// Whether a customer is signed in on this device.
///
/// A sealed type with exactly two cases, so a screen handles both with an exhaustive `switch`. Who the customer is
/// (name, contacts) is not part of it: the account feature reads that from the server.
sealed class SessionState {
  const new();
}

/// Nobody is signed in: no token is stored.
final class SignedOut extends SessionState {
  /// Creates the state; [expired] is `true` when the server refused the token, so the customer has to sign in again.
  const new({this.expired = false});

  /// Whether the session ended because the server no longer accepts the token (a `401`), as opposed to the customer
  /// signing out or never having signed in.
  final bool expired;
}

/// A customer is signed in: a token is stored and the server has not refused it.
final class SignedIn extends SessionState {
  /// Creates the state.
  const new();
}
