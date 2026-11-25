import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/core/l10n/locale_controller.dart';
import 'package:wasli_customer/features/account/application/account_providers.dart';
import 'package:wasli_customer/features/account/application/pending_verification.dart';
import 'package:wasli_customer/features/account/domain/account_contact.dart';
import 'package:wasli_customer/features/account/domain/customer_language.dart';

/// The sign-up call: idle, running, or failed with the `Failure` it threw.
final AsyncNotifierProvider<SignUpController, void> signUpControllerProvider =
    AsyncNotifierProvider.autoDispose<SignUpController, void>(SignUpController.new);

/// Creates the account and records the code that was sent.
///
/// The account's language is the language the app shows now, so the code message arrives in the language the customer
/// is reading. On success the [pendingVerificationProvider] holds the code and the screen moves to the code screen.
class SignUpController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Signs up with [fullName], [contact] and [password].
  Future<void> submit({required String fullName, required AccountContact contact, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final sent = await ref
          .read(accountRepositoryProvider)
          .signUp(
            fullName: fullName,
            contact: contact,
            password: password,
            language: CustomerLanguage.fromCode(ref.read(localeProvider).languageCode),
          );
      ref.read(pendingVerificationProvider.notifier).start(sent);
    });
  }
}
