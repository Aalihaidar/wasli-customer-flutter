import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/api/api.dart' as api;
import 'package:wasli_customer/core/error/api_error_code.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/features/account/data/account_mapper.dart';
import 'package:wasli_customer/features/account/data/account_repository_impl.dart';
import 'package:wasli_customer/features/account/domain/account_contact.dart';
import 'package:wasli_customer/features/account/domain/code_channel.dart';
import 'package:wasli_customer/features/account/domain/customer_language.dart';

import '../../../support/api_fixtures.dart';
import '../../../support/fake_http_adapter.dart';
import '../../../support/network_harness.dart';

/// The JSON body of [request], whether the client left it as a map or already encoded it.
Map<String, Object?> _body(RequestOptions request) {
  final data = request.data;
  final decoded = data is String ? jsonDecode(data) : data;
  return Map<String, Object?>.from(decoded as Map<Object?, Object?>);
}

void main() {
  group('the account mappers', () {
    test('read the profile of GET /customers/me', () {
      final customer = customerFromDto(api.CustomerProfile$Response.fromJson(readApiFixture('customers_me_200')));

      expect(customer.fullName, 'Sara Demo');
      expect(customer.language, CustomerLanguage.english);
      expect(customer.email, 'sara@example.com');
      expect(customer.emailVerified, isTrue);
      expect(customer.phone, isNull);
      expect(customer.phoneVerified, isFalse);
    });

    test('read a language the product does not have as English', () {
      final json = {...readApiFixture('customers_me_200'), 'locale': 'fr'};

      expect(customerFromDto(api.CustomerProfile$Response.fromJson(json)).language, CustomerLanguage.english);
      expect(CustomerLanguage.fromCode('ar'), CustomerLanguage.arabic);
    });

    test('read the token and the profile of verify and login', () {
      final session = customerSessionFromDto(api.Session$Response.fromJson(readApiFixture('customers_verify_200')));

      expect(session.token, 'demo-token-not-a-real-token');
      expect(session.customer.id, '3f2b8c1e-7a4d-4e6b-9c1a-5d2e8f0b1a11');
    });

    test('read a sent code as durations, and a channel added later as unknown', () {
      final sent = sentCodeFromDto(api.SentCode.fromJson(readApiFixture('customers_signup_201')));

      expect(sent.identifier, 'sara@example.com');
      expect(sent.channel, CodeChannel.email);
      expect(sent.expiresIn, const Duration(seconds: 600));
      expect(sent.resendAvailableIn, const Duration(seconds: 60));

      final later = {...readApiFixture('customers_signup_201'), 'channel': 'whatsapp'};
      expect(sentCodeFromDto(api.SentCode.fromJson(later)).channel, CodeChannel.unknown);
      final sms = {...readApiFixture('customers_signup_201'), 'channel': 'sms'};
      expect(sentCodeFromDto(api.SentCode.fromJson(sms)).channel, CodeChannel.sms);
    });
  });

  group('AccountRepositoryImpl', () {
    NetworkHarness harnessAnswering(int status, Object? body, {String? token}) =>
        NetworkHarness((_) => jsonResponse(status, body), token: token);

    AccountRepositoryImpl repositoryOver(NetworkHarness harness) => AccountRepositoryImpl.fromDio(harness.dio);

    test('sign-up with an email sends the email only, the language and no token', () async {
      final harness = harnessAnswering(201, readApiFixture('customers_signup_201'), token: 'stored-token');

      final sent = await repositoryOver(harness).signUp(
        fullName: 'Sara Demo',
        contact: const EmailContact('sara@example.com'),
        password: 'a-long-demo-password',
        language: CustomerLanguage.arabic,
      );

      final request = harness.adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/v1/customers/signup');
      expect(_body(request), {
        'full_name': 'Sara Demo',
        'email': 'sara@example.com',
        'password': 'a-long-demo-password',
        'locale': 'ar',
      });
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(sent.channel, CodeChannel.email);
    });

    test('sign-up with a phone sends the phone only', () async {
      final harness = harnessAnswering(201, {...readApiFixture('customers_signup_201'), 'channel': 'sms'});

      await repositoryOver(harness).signUp(
        fullName: 'Sara Demo',
        contact: const PhoneContact('+971500000000'),
        password: 'a-long-demo-password',
        language: CustomerLanguage.english,
      );

      final body = _body(harness.adapter.requests.single);
      expect(body['phone'], '+971500000000');
      expect(body.containsKey('email'), isFalse);
    });

    test('a contact that belongs to another account is a conflict', () async {
      final harness = harnessAnswering(409, readApiFixture('errors/account_exists_409'));

      await expectLater(
        repositoryOver(harness).signUp(
          fullName: 'Sara Demo',
          contact: const EmailContact('sara@example.com'),
          password: 'a-long-demo-password',
          language: CustomerLanguage.english,
        ),
        throwsA(isA<ConflictFailure>().having((f) => f.has(ApiErrorCode.accountExists), 'account_exists', isTrue)),
      );
    });

    test('verify sends the identifier and the code, without a token, and returns the session', () async {
      final harness = harnessAnswering(200, readApiFixture('customers_verify_200'), token: 'stored-token');

      final session = await repositoryOver(harness).verify(identifier: 'sara@example.com', code: '123456');

      final request = harness.adapter.requests.single;
      expect(request.uri.path, '/api/v1/customers/verify');
      expect(_body(request), {'identifier': 'sara@example.com', 'code': '123456'});
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(session.token, 'demo-token-not-a-real-token');
    });

    test('login sends the identifier and the password, without a token', () async {
      final harness = harnessAnswering(200, readApiFixture('customers_login_200'), token: 'stored-token');

      await repositoryOver(harness).logIn(identifier: '+971500000000', password: 'a-long-demo-password');

      final request = harness.adapter.requests.single;
      expect(request.uri.path, '/api/v1/customers/login');
      expect(_body(request), {'identifier': '+971500000000', 'password': 'a-long-demo-password'});
      expect(request.headers.containsKey('Authorization'), isFalse);
    });

    test('resend-code sends the identifier only', () async {
      final harness = harnessAnswering(202, readApiFixture('customers_resend_code_202'));

      await repositoryOver(harness).resendCode(identifier: 'sara@example.com');

      final request = harness.adapter.requests.single;
      expect(request.uri.path, '/api/v1/customers/resend-code');
      expect(_body(request), {'identifier': 'sara@example.com'});
    });

    test('a wrong or expired code arrives as a validation failure with its code', () async {
      final harness = harnessAnswering(400, {
        'type': 'validation_error',
        'errors': [
          {'code': 'code_invalid', 'detail': 'The code is wrong.', 'attr': 'code'},
        ],
      });

      await expectLater(
        repositoryOver(harness).verify(identifier: 'sara@example.com', code: '000000'),
        throwsA(isA<ValidationFailure>().having((f) => f.has(ApiErrorCode.codeInvalid), 'code_invalid', isTrue)),
      );
    });

    test('logout, me and the contact calls carry the stored token', () async {
      final harness = NetworkHarness((options) {
        return switch (options.uri.path) {
          '/api/v1/customers/logout' => jsonResponse(204, null),
          '/api/v1/customers/me' => jsonResponse(200, readApiFixture('customers_me_200')),
          '/api/v1/customers/me/contact' => jsonResponse(202, readApiFixture('customers_contact_add_202')),
          _ => jsonResponse(200, readApiFixture('customers_contact_verify_200')),
        };
      }, token: 'stored-token');
      final repository = repositoryOver(harness);

      await repository.logOut();
      await repository.currentCustomer();
      await repository.addContact(const PhoneContact('+971500000000'));
      await repository.verifyContact(code: '123456');

      final requests = harness.adapter.requests;
      expect(requests.map((r) => r.uri.path), [
        '/api/v1/customers/logout',
        '/api/v1/customers/me',
        '/api/v1/customers/me/contact',
        '/api/v1/customers/me/contact/verify',
      ]);
      for (final request in requests) {
        expect(request.headers['Authorization'], 'Customer stored-token', reason: request.uri.path);
      }
      expect(_body(requests[2]), {'phone': '+971500000000'});
      expect(_body(requests[3]), {'code': '123456'});
    });

    test('adding an email sends the email only', () async {
      final harness = harnessAnswering(202, readApiFixture('customers_contact_add_202'), token: 'stored-token');

      await repositoryOver(harness).addContact(const EmailContact('sara@example.com'));

      expect(_body(harness.adapter.requests.single), {'email': 'sara@example.com'});
    });

    test('a refused token ends the session once and fails as unauthenticated', () async {
      final harness = harnessAnswering(401, readApiFixture('errors/authentication_failed_401'), token: 'old-token');

      await expectLater(repositoryOver(harness).currentCustomer(), throwsA(isA<UnauthenticatedFailure>()));

      expect(harness.sessionExpiredCount, 1);
      expect(await harness.store.read(), isNull);
    });

    test('a password reset returns how long the code is valid, then the new password goes with the code', () async {
      final harness = NetworkHarness((options) {
        return options.uri.path.endsWith('/confirm')
            ? ResponseBody.fromString('', 204)
            : jsonResponse(202, readApiFixture('customers_password_reset_202'));
      });
      final repository = repositoryOver(harness);

      final validFor = await repository.requestPasswordReset(identifier: 'sara@example.com');
      await repository.resetPassword(
        identifier: 'sara@example.com',
        code: '123456',
        newPassword: 'another-demo-password',
      );

      expect(validFor, const Duration(seconds: 600));
      final requests = harness.adapter.requests;
      expect(requests[0].uri.path, '/api/v1/customers/password-reset');
      expect(_body(requests[0]), {'identifier': 'sara@example.com'});
      expect(requests[1].uri.path, '/api/v1/customers/password-reset/confirm');
      expect(_body(requests[1]), {
        'identifier': 'sara@example.com',
        'code': '123456',
        'new_password': 'another-demo-password',
      });
    });

    test('too many wrong codes arrives as a throttled failure', () async {
      final harness = harnessAnswering(429, {
        'type': 'client_error',
        'errors': [
          {'code': 'too_many_attempts', 'detail': 'Too many attempts.', 'attr': null},
        ],
      });

      await expectLater(
        repositoryOver(harness).verify(identifier: 'sara@example.com', code: '000000'),
        throwsA(isA<ThrottledFailure>().having((f) => f.tooManyAttempts, 'tooManyAttempts', isTrue)),
      );
    });
  });
}
