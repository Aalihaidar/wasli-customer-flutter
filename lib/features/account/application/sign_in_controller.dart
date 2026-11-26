import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/session/session_controller.dart';
import 'package:wasli_customer/features/account/application/account_providers.dart';
import 'package:wasli_customer/features/account/application/pending_verification.dart';

/// The sign-in call: idle, running, or failed with the `Failure` it threw.
final AsyncNotifierProvider<SignInController, void> signInControllerProvider =
    AsyncNotifierProvider.autoDispose<SignInController, void>(SignInController.new);

/// Signs the customer in, or sends them to confirm the account when it was never confirmed.
class SignInController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Signs in with the email or phone [identifier] and the [password].
  ///
  /// On success the session holds the token. When the server says the account is not confirmed yet
  /// (`account_not_verified`), a new code is requested and recorded as the pending verification, so the screen moves to
  /// the code page; a failure of that request is the failure shown.
  Future<void> submit({required String identifier, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(accountRepositoryProvider);
      try {
        final session = await repository.logIn(identifier: identifier, password: password);
        await ref.read(sessionProvider.notifier).signIn(session.token);
      } on AccountNotVerifiedFailure {
        final sent = await repository.resendCode(identifier: identifier);
        ref.read(pendingVerificationProvider.notifier).start(sent);
      }
    });
  }
}
