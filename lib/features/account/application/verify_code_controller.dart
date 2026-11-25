import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/core/session/session_controller.dart';
import 'package:wasli_customer/features/account/application/account_providers.dart';
import 'package:wasli_customer/features/account/application/pending_verification.dart';

/// Confirming the code: idle, running, or failed with the `Failure` it threw.
final AsyncNotifierProvider<VerifyCodeController, void> verifyCodeControllerProvider =
    AsyncNotifierProvider.autoDispose<VerifyCodeController, void>(VerifyCodeController.new);

/// Sends the six digits and, when the server accepts them, signs the customer in with the token it returns.
class VerifyCodeController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Confirms [code] for the pending verification. Does nothing when there is none.
  Future<void> submit(String code) async {
    final pending = ref.read(pendingVerificationProvider);
    if (pending == null) {
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref.read(accountRepositoryProvider).verify(identifier: pending.sent.identifier, code: code);
      await ref.read(sessionProvider.notifier).signIn(session.token);
      ref.read(pendingVerificationProvider.notifier).clear();
    });
  }
}
