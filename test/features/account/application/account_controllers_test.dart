import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/locale_controller.dart';
import 'package:wasli_customer/core/logging/app_logger.dart';
import 'package:wasli_customer/core/session/session_controller.dart';
import 'package:wasli_customer/core/session/session_state.dart';
import 'package:wasli_customer/core/storage/token_store.dart';
import 'package:wasli_customer/core/time/clock.dart';
import 'package:wasli_customer/features/account/application/account_providers.dart';
import 'package:wasli_customer/features/account/application/add_contact_flow.dart';
import 'package:wasli_customer/features/account/application/confirm_password_reset_controller.dart';
import 'package:wasli_customer/features/account/application/customer_profile.dart';
import 'package:wasli_customer/features/account/application/password_reset_flow.dart';
import 'package:wasli_customer/features/account/application/pending_verification.dart';
import 'package:wasli_customer/features/account/application/request_password_reset_controller.dart';
import 'package:wasli_customer/features/account/application/resend_code_controller.dart';
import 'package:wasli_customer/features/account/application/send_contact_code_controller.dart';
import 'package:wasli_customer/features/account/application/sign_out_controller.dart';
import 'package:wasli_customer/features/account/application/sign_up_controller.dart';
import 'package:wasli_customer/features/account/application/verify_code_controller.dart';
import 'package:wasli_customer/features/account/application/verify_contact_controller.dart';
import 'package:wasli_customer/features/account/domain/account_contact.dart';
import 'package:wasli_customer/features/account/domain/customer_language.dart';

import '../../../support/fake_account_repository.dart';
import '../../../support/network_harness.dart';

void main() {
  late FakeAccountRepository repository;
  late MemoryTokenStore store;
  late DateTime now;
  late ProviderContainer container;

  setUp(() {
    repository = FakeAccountRepository();
    store = MemoryTokenStore();
    now = DateTime.utc(2026, 11, 25, 10);
    container = ProviderContainer(
      overrides: [
        accountRepositoryProvider.overrideWithValue(repository),
        tokenStoreProvider.overrideWithValue(store),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> signUp() => container
      .read(signUpControllerProvider.notifier)
      .submit(fullName: 'Sara Demo', contact: const EmailContact('sara@example.com'), password: 'a-demo-password');

  group('SignUpController', () {
    test('records the code that was sent, with the time it arrived', () async {
      await signUp();

      final pending = container.read(pendingVerificationProvider)!;
      expect(pending.sent.identifier, 'sara@example.com');
      expect(pending.sentAt, now);
      expect(pending.resendAvailableAt, now.add(const Duration(minutes: 1)));
      expect(pending.expiresAt, now.add(const Duration(minutes: 10)));
    });

    test('uses the language the app shows as the account language', () async {
      await signUp();
      expect(repository.lastLanguage, CustomerLanguage.english);

      container.read(localeProvider.notifier).setLocale(AppLocales.arabic);
      await signUp();
      expect(repository.lastLanguage, CustomerLanguage.arabic);
    });

    test('keeps the failure and records no code when the server refuses', () async {
      repository.onSignUp = (_, _) async => throw const UnexpectedFailure(statusCode: 500);
      final listener = container.listen(signUpControllerProvider, (_, _) {});

      await signUp();

      expect(listener.read().error, isA<UnexpectedFailure>());
      expect(container.read(pendingVerificationProvider), isNull);
    });
  });

  group('VerifyCodeController', () {
    test('signs the customer in with the token and forgets the pending code', () async {
      await signUp();

      await container.read(verifyCodeControllerProvider.notifier).submit('123456');

      expect(repository.lastCode, '123456');
      expect(container.read(sessionProvider), isA<SignedIn>());
      expect(await store.read(), demoSession.token);
      expect(container.read(pendingVerificationProvider), isNull);
    });

    test('stays signed out and keeps the pending code when the code is refused', () async {
      await signUp();
      repository.onVerify = (_, _) async => throw const ValidationFailure([]);
      final listener = container.listen(verifyCodeControllerProvider, (_, _) {});

      await container.read(verifyCodeControllerProvider.notifier).submit('000000');

      expect(listener.read().error, isA<ValidationFailure>());
      expect(container.read(sessionProvider), isA<SignedOut>());
      expect(container.read(pendingVerificationProvider), isNotNull);
    });

    test('does nothing without a pending code', () async {
      await container.read(verifyCodeControllerProvider.notifier).submit('123456');

      expect(repository.calls, isEmpty);
    });
  });

  group('ResendCodeController', () {
    test('asks again for the same identifier and restarts the countdowns', () async {
      await signUp();
      now = now.add(const Duration(minutes: 2));

      await container.read(resendCodeControllerProvider.notifier).submit();

      expect(repository.calls, ['signUp', 'resendCode']);
      expect(container.read(pendingVerificationProvider)!.sentAt, now);
    });

    test('keeps the old code and the failure when the server refuses', () async {
      await signUp();
      final first = container.read(pendingVerificationProvider);
      repository.onResend = (_) async => throw const ThrottledFailure();
      final listener = container.listen(resendCodeControllerProvider, (_, _) {});

      await container.read(resendCodeControllerProvider.notifier).submit();

      expect(listener.read().error, isA<ThrottledFailure>());
      expect(container.read(pendingVerificationProvider), same(first));
    });
  });

  group('SignOutController', () {
    late RecordingLogger logger;

    setUp(() {
      logger = RecordingLogger();
      container.dispose();
      container = ProviderContainer(
        overrides: [
          accountRepositoryProvider.overrideWithValue(repository),
          tokenStoreProvider.overrideWithValue(store),
          appLoggerProvider.overrideWithValue(logger),
        ],
      );
      addTearDown(container.dispose);
    });

    Future<void> signedIn() async {
      await container.read(sessionProvider.notifier).signIn('demo-token-not-a-real-token');
    }

    test('revokes the token on the server, forgets it here and moves to signed out', () async {
      await signedIn();

      await container.read(signOutControllerProvider.notifier).submit();

      expect(repository.calls, ['logOut']);
      expect(await store.read(), isNull);
      expect(container.read(sessionProvider), isA<SignedOut>());
      expect((container.read(sessionProvider) as SignedOut).expired, isFalse);
    });

    test('signs out here when the server could not be reached, and logs the kind of failure only', () async {
      await signedIn();
      repository.onLogOut = () async => throw const NetworkFailure(NetworkFailureKind.offline);

      await container.read(signOutControllerProvider.notifier).submit();

      expect(await store.read(), isNull);
      expect(container.read(sessionProvider), isA<SignedOut>());
      expect(logger.lines, ['warning: Sign-out was not confirmed by the server (NetworkFailure).']);
      expect(logger.lines.join(), isNot(contains('demo-token')));
    });

    test('finishes even when nothing watches it any more', () async {
      await signedIn();
      final done = container.read(signOutControllerProvider.notifier).submit();

      await done;

      expect(container.read(signOutControllerProvider).hasError, isFalse);
    });
  });

  group('adding a contact', () {
    // The page keeps the flow alive while it is open; the tests do the same.
    setUp(() => container.listen(addContactFlowProvider, (_, _) {}));

    test('SendContactCodeController records the contact with the code that was sent and when', () async {
      repository.onAddContact = (_) async => demoSentCode;

      await container.read(sendContactCodeControllerProvider.notifier).submit(const PhoneContact('+971500000000'));

      final flow = container.read(addContactFlowProvider)!;
      expect(flow.contact.value, '+971500000000');
      expect(flow.pending.sentAt, now);
      expect(flow.pending.resendAvailableAt, now.add(const Duration(minutes: 1)));
      expect(repository.lastAddedContact, isA<PhoneContact>());
    });

    test('SendContactCodeController keeps typing when the server refuses, and exposes the failure', () async {
      repository.onAddContact = (_) async => throw const ThrottledFailure();
      final listener = container.listen(sendContactCodeControllerProvider, (_, _) {});

      await container.read(sendContactCodeControllerProvider.notifier).submit(const PhoneContact('+971500000000'));

      expect(listener.read().error, isA<ThrottledFailure>());
      expect(container.read(addContactFlowProvider), isNull);
    });

    test('a resend asks again for the same contact and restarts the countdowns', () async {
      await container.read(sendContactCodeControllerProvider.notifier).submit(const EmailContact('sara@example.com'));
      now = now.add(const Duration(minutes: 2));

      await container.read(sendContactCodeControllerProvider.notifier).resend();

      expect(repository.calls, ['addContact', 'addContact']);
      expect(container.read(addContactFlowProvider)!.pending.sentAt, now);
      expect(container.read(addContactFlowProvider)!.contact.value, 'sara@example.com');
    });

    test('a resend with nothing to confirm does nothing', () async {
      await container.read(sendContactCodeControllerProvider.notifier).resend();

      expect(repository.calls, isEmpty);
    });

    test('VerifyContactController saves the contact, ends the flow and drops the stale profile', () async {
      var reads = 0;
      repository.onCurrentCustomer = () async => reads++ == 0 ? demoCustomer : demoCustomerWithPhone;
      final profile = container.listen(customerProfileProvider, (_, _) {});
      expect((await container.read(customerProfileProvider.future)).phone, isNull);
      await container.read(sendContactCodeControllerProvider.notifier).submit(const PhoneContact('+971500000000'));

      await container.read(verifyContactControllerProvider.notifier).submit('123456');

      expect(repository.lastContactCode, '123456');
      expect(container.read(addContactFlowProvider), isNull);
      expect((await container.read(customerProfileProvider.future)).phone, '+971500000000');
      expect(reads, 2);
      profile.close();
    });

    test('VerifyContactController keeps the flow and exposes the failure when the code is wrong', () async {
      repository.onVerifyContact = (_) async => throw const ThrottledFailure(tooManyAttempts: true);
      await container.read(sendContactCodeControllerProvider.notifier).submit(const PhoneContact('+971500000000'));
      final listener = container.listen(verifyContactControllerProvider, (_, _) {});

      await container.read(verifyContactControllerProvider.notifier).submit('000000');

      expect(listener.read().error, isA<ThrottledFailure>());
      expect(container.read(addContactFlowProvider), isNotNull);
    });

    test('VerifyContactController sends nothing when no contact is being confirmed', () async {
      await container.read(verifyContactControllerProvider.notifier).submit('123456');

      expect(repository.calls, isEmpty);
    });
  });

  group('resetting a forgotten password', () {
    // The page keeps the flow alive while it is open; the tests do the same.
    setUp(() => container.listen(passwordResetFlowProvider, (_, _) {}));

    Future<void> request([String identifier = 'sara@example.com']) =>
        container.read(requestPasswordResetControllerProvider.notifier).submit(identifier);

    test('starts at the contact field', () {
      expect(container.read(passwordResetFlowProvider), isA<ResetEnteringContact>());
    });

    test('asking for a code moves to the code step and records when it stops working', () async {
      await request();

      final step = container.read(passwordResetFlowProvider) as ResetEnteringCode;
      expect(step.identifier, 'sara@example.com');
      expect(step.expiresAt, now.add(const Duration(minutes: 10)));
    });

    test('a refused request stays on the contact field and exposes the failure', () async {
      repository.onRequestPasswordReset = (_) async => throw const ThrottledFailure();
      final listener = container.listen(requestPasswordResetControllerProvider, (_, _) {});

      await request();

      expect(listener.read().error, isA<ThrottledFailure>());
      expect(container.read(passwordResetFlowProvider), isA<ResetEnteringContact>());
    });

    test('a resend asks again for the same contact and restarts the expiry', () async {
      await request('+971500000000');
      now = now.add(const Duration(minutes: 3));

      await container.read(requestPasswordResetControllerProvider.notifier).resend();

      expect(repository.calls, ['requestPasswordReset', 'requestPasswordReset']);
      final step = container.read(passwordResetFlowProvider) as ResetEnteringCode;
      expect(step.identifier, '+971500000000');
      expect(step.expiresAt, now.add(const Duration(minutes: 10)));
    });

    test('a resend before any request does nothing', () async {
      await container.read(requestPasswordResetControllerProvider.notifier).resend();

      expect(repository.calls, isEmpty);
    });

    test('confirming sends the contact, the code and the new password, and ends the flow', () async {
      await request();

      await container
          .read(confirmPasswordResetControllerProvider.notifier)
          .submit(code: '123456', newPassword: 'a-new-demo-password');

      expect(repository.lastResetIdentifier, 'sara@example.com');
      expect(repository.lastResetCode, '123456');
      expect(repository.lastNewPassword, 'a-new-demo-password');
      expect(container.read(passwordResetFlowProvider), isA<ResetDone>());
    });

    test('a refused confirmation stays on the code step and exposes the failure', () async {
      repository.onResetPassword = (_, _, _) async => throw const ThrottledFailure(tooManyAttempts: true);
      await request();
      final listener = container.listen(confirmPasswordResetControllerProvider, (_, _) {});

      await container
          .read(confirmPasswordResetControllerProvider.notifier)
          .submit(code: '000000', newPassword: 'a-new-demo-password');

      expect(listener.read().error, isA<ThrottledFailure>());
      expect(container.read(passwordResetFlowProvider), isA<ResetEnteringCode>());
    });

    test('confirming before any code was asked for sends nothing', () async {
      await container
          .read(confirmPasswordResetControllerProvider.notifier)
          .submit(code: '123456', newPassword: 'a-new-demo-password');

      expect(repository.calls, isEmpty);
    });
  });
}
