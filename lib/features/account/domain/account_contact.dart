/// An email address or a phone number: the two ways a customer is known to the server.
///
/// A sealed type, so a screen that takes either handles both with an exhaustive `switch`.
sealed class AccountContact {
  const new(this.value);

  /// The address or number, as the customer typed it (the server checks it).
  final String value;
}

/// An email address.
final class EmailContact extends AccountContact {
  /// Creates an email contact.
  const new(super.value);
}

/// A phone number.
final class PhoneContact extends AccountContact {
  /// Creates a phone contact.
  const new(super.value);
}
