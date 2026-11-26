import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/core/time/clock.dart';
import 'package:wasli_customer/features/account/application/account_providers.dart';
import 'package:wasli_customer/features/account/application/add_contact_flow.dart';
import 'package:wasli_customer/features/account/application/pending_verification.dart';
import 'package:wasli_customer/features/account/domain/account_contact.dart';

/// Asking the server to send a code to a contact: idle, running, or failed with the `Failure` it threw.
final AsyncNotifierProvider<SendContactCodeController, void> sendContactCodeControllerProvider =
    AsyncNotifierProvider.autoDispose<SendContactCodeController, void>(SendContactCodeController.new);

/// Sends a code to the contact being added, the first time and again on a resend.
class SendContactCodeController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Asks the server to send a code to [contact] and moves the page on to the code step.
  Future<void> submit(AccountContact contact) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final sent = await ref.read(accountRepositoryProvider).addContact(contact);
      ref.read(addContactFlowProvider.notifier).verification = ContactVerification(
        contact: contact,
        pending: PendingVerification(sent: sent, sentAt: ref.read(clockProvider)()),
      );
    });
  }

  /// Sends a new code to the contact that is being confirmed. Does nothing when there is none.
  Future<void> resend() async {
    final current = ref.read(addContactFlowProvider);
    if (current != null) {
      await submit(current.contact);
    }
  }
}
