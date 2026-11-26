import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/logging/app_logger.dart';
import 'package:wasli_customer/core/session/session_controller.dart';
import 'package:wasli_customer/features/account/application/account_providers.dart';

/// Signing out: idle or running. It never fails: the customer is always signed out on this device.
///
/// Not auto-disposed: the screen that shows the progress is replaced by the signed-out view while the call is still
/// running, and the sign-out must finish whether or not anything is watching.
final signOutControllerProvider = AsyncNotifierProvider<SignOutController, void>(SignOutController.new);

/// Revokes this device's token on the server, then forgets it here.
class SignOutController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Signs the customer out.
  ///
  /// The server is asked first so the token stops working everywhere. When that call fails (offline, a server error) the
  /// customer is signed out on this device all the same, because a button that says "Sign out" must never leave the
  /// account open; the token then stays valid on the server until it is revoked some other way (backend tokens have no
  /// expiry in v1), which is logged as a warning without any detail.
  Future<void> submit() async {
    state = const AsyncLoading();
    try {
      await ref.read(accountRepositoryProvider).logOut();
    } on Failure catch (failure) {
      ref.read(appLoggerProvider).warning('Sign-out was not confirmed by the server (${failure.runtimeType}).');
    }
    await ref.read(sessionProvider.notifier).signOut();
    state = const AsyncData(null);
  }
}
