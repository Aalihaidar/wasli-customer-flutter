import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the customer is in resetting a forgotten password.
///
/// A sealed type with one case per screen state, so the page handles each with an exhaustive `switch`.
sealed class PasswordResetState {
  const new();
}

/// Typing the email or phone number of the account.
final class ResetEnteringContact extends PasswordResetState {
  /// Creates the state.
  const new();
}

/// A code was requested for [identifier]; the customer types it with a new password.
final class ResetEnteringCode extends PasswordResetState {
  /// Creates the state for a code that stops working at [expiresAt] (UTC).
  const new({required this.identifier, required this.expiresAt});

  /// The email or phone the customer asked a code for, as they typed it.
  final String identifier;

  /// When the code stops working.
  final DateTime expiresAt;
}

/// The password was changed. The server has signed the customer out of every device.
final class ResetDone extends PasswordResetState {
  /// Creates the state.
  const new();
}

/// The step the page shows. Dropped when the page closes, so a new visit starts from the field.
final NotifierProvider<PasswordResetFlow, PasswordResetState> passwordResetFlowProvider =
    NotifierProvider.autoDispose<PasswordResetFlow, PasswordResetState>(PasswordResetFlow.new);

/// Holds the [PasswordResetState].
class PasswordResetFlow extends Notifier<PasswordResetState> {
  @override
  PasswordResetState build() => const ResetEnteringContact();

  /// The step the customer is on.
  PasswordResetState get step => state;

  /// Moves to [value].
  set step(PasswordResetState value) => state = value;
}
