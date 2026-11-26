import 'package:wasli_customer/features/account/domain/contact_kind.dart';
import 'package:wasli_customer/features/account/domain/customer_language.dart';

/// The signed-in customer's profile, as the server holds it.
///
/// A customer has an email, a phone, or both; each is verified separately. A customer who signed up with an email must
/// verify a phone before the first order (`architecture.md`, section 7b).
class Customer {
  /// Creates a profile.
  const new({
    required this.id,
    required this.fullName,
    required this.language,
    required this.email,
    required this.emailVerified,
    required this.phone,
    required this.phoneVerified,
  });

  /// The customer's id (a UUID).
  final String id;

  /// The name the customer gave at sign-up.
  final String fullName;

  /// The language of the account.
  final CustomerLanguage language;

  /// The email address, or `null` when the customer signed up with a phone and has not added one.
  final String? email;

  /// Whether the email address was confirmed with a code.
  final bool emailVerified;

  /// The phone number, or `null` when the customer signed up with an email and has not added one.
  final String? phone;

  /// Whether the phone number was confirmed with a code.
  final bool phoneVerified;

  /// The kind of contact the customer can still add from the settings, or `null` when they have both.
  ///
  /// A customer is known by an email, a phone, or both, so at most one kind is missing. A contact that is set is never
  /// replaced (`contact_already_set`), so this is the only one the app offers.
  ContactKind? get missingContact {
    if (email == null) {
      return ContactKind.email;
    }
    if (phone == null) {
      return ContactKind.phone;
    }
    return null;
  }
}
