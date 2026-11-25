import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/features/account/application/contact_input.dart';
import 'package:wasli_customer/features/account/domain/account_contact.dart';

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
}
