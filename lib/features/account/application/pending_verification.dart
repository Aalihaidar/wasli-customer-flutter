import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/core/time/clock.dart';
import 'package:wasli_customer/features/account/domain/sent_code.dart';

/// A code the customer has been sent and has not entered yet: what the code screen shows, and when it can ask again.
class PendingVerification {
  /// Creates the state for a code sent at [sentAt] (UTC).
  const new({required this.sent, required this.sentAt});

  /// The code that was sent.
  final SentCode sent;

  /// When the answer arrived; the lifetime and the resend delay count from here.
  final DateTime sentAt;

  /// When a new code may be asked for.
  DateTime get resendAvailableAt => sentAt.add(sent.resendAvailableIn);

  /// When the code stops working.
  DateTime get expiresAt => sentAt.add(sent.expiresIn);
}

/// The code waiting to be entered, or `null`. Set by sign-up and by a resend, cleared when the code is accepted.
final pendingVerificationProvider = NotifierProvider<PendingVerificationController, PendingVerification?>(
  PendingVerificationController.new,
);

/// Holds the [PendingVerification].
class PendingVerificationController extends Notifier<PendingVerification?> {
  @override
  PendingVerification? build() => null;

  /// Records that [sent] has just been sent.
  void start(SentCode sent) => state = PendingVerification(sent: sent, sentAt: ref.read(clockProvider)());

  /// Forgets the pending code.
  void clear() => state = null;
}
