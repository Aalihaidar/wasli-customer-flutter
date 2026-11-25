/// How a verification code reached the customer.
enum CodeChannel {
  /// By email.
  email,

  /// By text message.
  sms,

  /// A way this version of the app does not know; the screen then speaks of "the code we sent" without naming it.
  unknown,
}
