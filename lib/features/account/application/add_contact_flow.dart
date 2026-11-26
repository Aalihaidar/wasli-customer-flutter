import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/features/account/application/pending_verification.dart';
import 'package:wasli_customer/features/account/domain/account_contact.dart';

/// A contact the customer is adding and the code that was sent to confirm it.
class ContactVerification {
  /// Creates the state: the [contact] being added and the code [pending] for it.
  const new({required this.contact, required this.pending});

  /// The email or phone the customer typed.
  final AccountContact contact;

  /// The code that was sent to it, with its countdowns.
  final PendingVerification pending;
}

/// The contact being confirmed, or `null` while the customer is still typing it.
///
/// Dropped when the page closes: a code that was sent stays valid on the server, but the customer starts again from the
/// field, which is the only way to ask for a new one.
final NotifierProvider<AddContactFlow, ContactVerification?> addContactFlowProvider =
    NotifierProvider.autoDispose<AddContactFlow, ContactVerification?>(AddContactFlow.new);

/// Holds the [ContactVerification].
class AddContactFlow extends Notifier<ContactVerification?> {
  @override
  ContactVerification? build() => null;

  /// The contact being confirmed, or `null` while the customer is still typing it.
  ContactVerification? get verification => state;

  /// Records that a code has just been sent for this contact, or, with `null`, goes back to typing the contact.
  set verification(ContactVerification? value) => state = value;
}
