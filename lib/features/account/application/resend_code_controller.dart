import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/features/account/application/account_providers.dart';
import 'package:wasli_customer/features/account/application/pending_verification.dart';

/// Asking for a new code: idle, running, or failed with the `Failure` it threw.
final AsyncNotifierProvider<ResendCodeController, void> resendCodeControllerProvider =
    AsyncNotifierProvider.autoDispose<ResendCodeController, void>(ResendCodeController.new);

/// Asks the server for a new code and restarts the countdowns with the answer.
class ResendCodeController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Sends a new code to the identifier of the pending verification. Does nothing when there is none.
  Future<void> submit() async {
    final pending = ref.read(pendingVerificationProvider);
    if (pending == null) {
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final sent = await ref.read(accountRepositoryProvider).resendCode(identifier: pending.sent.identifier);
      ref.read(pendingVerificationProvider.notifier).start(sent);
    });
  }
}
