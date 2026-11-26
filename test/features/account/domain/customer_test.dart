import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/features/account/domain/contact_kind.dart';

import '../../../support/fake_account_repository.dart';

void main() {
  group('Customer.missingContact', () {
    test('is the phone for a customer who has only an email', () {
      expect(demoCustomer.missingContact, ContactKind.phone);
    });

    test('is the email for a customer who has only a phone', () {
      expect(demoPhoneCustomer.missingContact, ContactKind.email);
    });

    test('is nothing for a customer who has both', () {
      expect(demoCustomerWithPhone.missingContact, isNull);
    });
  });
}
