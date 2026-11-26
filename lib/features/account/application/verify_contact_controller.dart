import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/features/account/application/account_providers.dart';
import 'package:wasli_customer/features/account/application/add_contact_flow.dart';
import 'package:wasli_customer/features/account/application/customer_profile.dart';

/// Confirming the code for the contact being added: idle, running, or failed with the `Failure` it threw.
final AsyncNotifierProvider<VerifyContactController, void> verifyContactControllerProvider =
    AsyncNotifierProvider.autoDispose<VerifyContactController, void>(VerifyContactController.new);

/// Sends the six digits and, when the server accepts them, saves the contact on the account.
class VerifyContactController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Confirms [code]. On success the profile is read again, so the settings show the new contact, and the flow ends.
  Future<void> submit(String code) async {
    if (ref.read(addContactFlowProvider) == null) {
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(accountRepositoryProvider).verifyContact(code: code);
      ref.invalidate(customerProfileProvider);
      ref.read(addContactFlowProvider.notifier).verification = null;
    });
  }
}
