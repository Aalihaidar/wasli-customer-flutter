import 'package:wasli_customer/core/format/western_digits.dart';
import 'package:wasli_customer/features/account/domain/account_contact.dart';
import 'package:wasli_customer/features/account/domain/contact_kind.dart';

final RegExp _phoneSeparators = RegExp(r'[\s\-().]');

/// Reads what the customer typed in the "email or phone number" field as an [AccountContact], or `null` when it is
/// empty.
///
/// Text with an `@` is an email address, anything else a phone number. Arabic-Indic digits become Western ones, and for a
/// phone number the spaces, dashes, dots and brackets are dropped (a leading `+` stays). This only decides which kind
/// of contact it is and tidies the typing; the server decides whether the address or number is valid.
AccountContact? contactFromInput(String input) {
  final text = toWesternDigits(input.trim());
  if (text.isEmpty) {
    return null;
  }
  if (text.contains('@')) {
    return EmailContact(text);
  }
  final phone = text.replaceAll(_phoneSeparators, '');
  return phone.isEmpty ? null : PhoneContact(phone);
}

/// Reads what the customer typed in a field that asks for one [kind] of contact, or `null` when it is empty.
///
/// The same tidying as [contactFromInput] (Western digits; for a phone number the separators are dropped), but the
/// kind is the field's, not guessed from an `@`: a phone field never turns into an email. The server decides whether the
/// value is valid.
AccountContact? contactOfKind(ContactKind kind, String input) {
  final text = toWesternDigits(input.trim());
  switch (kind) {
    case ContactKind.email:
      return text.isEmpty ? null : EmailContact(text);
    case ContactKind.phone:
      final phone = text.replaceAll(_phoneSeparators, '');
      return phone.isEmpty ? null : PhoneContact(phone);
  }
}
