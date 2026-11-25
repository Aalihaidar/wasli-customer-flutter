import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/locale_controller.dart';
import 'package:wasli_customer/core/session/session_controller.dart';
import 'package:wasli_customer/core/session/session_state.dart';
import 'package:wasli_customer/core/storage/token_store.dart';
import 'package:wasli_customer/core/time/clock.dart';
import 'package:wasli_customer/features/account/application/account_providers.dart';
import 'package:wasli_customer/features/account/application/pending_verification.dart';
import 'package:wasli_customer/features/account/application/resend_code_controller.dart';
import 'package:wasli_customer/features/account/application/sign_up_controller.dart';
import 'package:wasli_customer/features/account/application/verify_code_controller.dart';
import 'package:wasli_customer/features/account/domain/account_contact.dart';
import 'package:wasli_customer/features/account/domain/customer_language.dart';

import '../../../support/fake_account_repository.dart';

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
}
