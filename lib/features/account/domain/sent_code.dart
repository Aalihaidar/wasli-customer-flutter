import 'package:wasli_customer/features/account/domain/code_channel.dart';

/// A verification code the server has just sent, and what the code screen needs to show.
class SentCode {
  /// Creates the description of a sent code.
  const new({
    required this.identifier,
    required this.channel,
    required this.expiresIn,
    required this.resendAvailableIn,
  });

  /// The email or phone the code went to, as the server stores it; it goes back with the code at `verify`.
  final String identifier;

  /// How the code was sent.
  final CodeChannel channel;

  /// How long the code is valid, counted from the answer.
  final Duration expiresIn;

  /// How long to wait before asking for a new code, counted from the answer.
  final Duration resendAvailableIn;
}
