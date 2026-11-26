import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/features/account/application/contact_input.dart';
import 'package:wasli_customer/features/account/domain/account_contact.dart';
import 'package:wasli_customer/features/account/domain/contact_kind.dart';

void main() {
  group('contactFromInput', () {
    test('reads text with an @ as an email address, trimmed', () {
      final contact = contactFromInput('  sara@example.com ');

      expect(contact, isA<EmailContact>());
      expect(contact!.value, 'sara@example.com');
    });

    test('reads anything else as a phone number without spaces, dashes, dots and brackets', () {
      final contact = contactFromInput('+971 (50) 000-00.00');

      expect(contact, isA<PhoneContact>());
      expect(contact!.value, '+971500000000');
    });

    test('turns Arabic-Indic digits into Western ones', () {
      expect(contactFromInput('٠٥٠٠٠٠٠٠٠٠')!.value, '0500000000');
    });

    test('is null for an empty field or one with only separators', () {
      expect(contactFromInput(''), isNull);
      expect(contactFromInput('   '), isNull);
      expect(contactFromInput(' - () '), isNull);
    });
  });

  group('contactOfKind', () {
    test('reads an email field as an email, trimmed and with Western digits', () {
      final contact = contactOfKind(ContactKind.email, '  sara٢@example.com ');

      expect(contact, isA<EmailContact>());
      expect(contact!.value, 'sara2@example.com');
    });

    test('reads a phone field as a phone with the separators dropped and a leading + kept', () {
      final contact = contactOfKind(ContactKind.phone, '+971 (50) 000-00.00');

      expect(contact, isA<PhoneContact>());
      expect(contact!.value, '+971500000000');
    });

    test('turns Arabic-Indic digits of a phone number into Western ones', () {
      expect(contactOfKind(ContactKind.phone, '٠٥٠ ١٢٣ ٤٥٦٧')!.value, '0501234567');
    });

    test('keeps the kind of the field even when the text has an @ or none', () {
      expect(contactOfKind(ContactKind.phone, 'sara@example.com'), isA<PhoneContact>());
      expect(contactOfKind(ContactKind.email, '0501234567'), isA<EmailContact>());
    });

    test('is null for empty text and for a phone that is only separators', () {
      expect(contactOfKind(ContactKind.email, '   '), isNull);
      expect(contactOfKind(ContactKind.phone, ''), isNull);
      expect(contactOfKind(ContactKind.phone, ' - ( ) '), isNull);
    });
  });
}
