import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/core/time/clock.dart';
import 'package:wasli_customer/features/account/application/account_providers.dart';
import 'package:wasli_customer/features/account/application/password_reset_flow.dart';

/// Asking for a password-reset code: idle, running, or failed with the `Failure` it threw.
final AsyncNotifierProvider<RequestPasswordResetController, void> requestPasswordResetControllerProvider =
    AsyncNotifierProvider.autoDispose<RequestPasswordResetController, void>(RequestPasswordResetController.new);

/// Asks the server to send a reset code, the first time and again on a resend.
///
/// The server answers the same whether or not an account exists for the contact, so the page never learns which.
class RequestPasswordResetController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Asks for a code for the email or phone [identifier] and moves the page on to the code step.
  Future<void> submit(String identifier) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final expiresIn = await ref.read(accountRepositoryProvider).requestPasswordReset(identifier: identifier);
      ref.read(passwordResetFlowProvider.notifier).step = ResetEnteringCode(
        identifier: identifier,
        expiresAt: ref.read(clockProvider)().add(expiresIn),
      );
    });
  }

  /// Asks for a new code for the same contact. Does nothing when no code was asked for yet.
  Future<void> resend() async {
    if (ref.read(passwordResetFlowProvider) case ResetEnteringCode(:final identifier)) {
      await submit(identifier);
    }
  }
}
