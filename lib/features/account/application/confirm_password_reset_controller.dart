import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/features/account/application/account_providers.dart';
import 'package:wasli_customer/features/account/application/password_reset_flow.dart';

/// Setting the new password: idle, running, or failed with the `Failure` it threw.
final AsyncNotifierProvider<ConfirmPasswordResetController, void> confirmPasswordResetControllerProvider =
    AsyncNotifierProvider.autoDispose<ConfirmPasswordResetController, void>(ConfirmPasswordResetController.new);

/// Sends the code and the new password. The server then revokes every token of the customer.
class ConfirmPasswordResetController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Sets [newPassword] with [code] for the contact the code was asked for. Does nothing when no code was asked for.
  Future<void> submit({required String code, required String newPassword}) async {
    final step = ref.read(passwordResetFlowProvider);
    if (step is! ResetEnteringCode) {
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(accountRepositoryProvider)
          .resetPassword(identifier: step.identifier, code: code, newPassword: newPassword);
      ref.read(passwordResetFlowProvider.notifier).step = const ResetDone();
    });
  }
}
