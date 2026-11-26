import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/features/account/domain/customer.dart';
import 'package:wasli_customer/features/account/domain/customer_language.dart';

import '../../../support/bidi.dart';
import '../../../support/fake_account_repository.dart';
import '../../../support/pump_app.dart';

Finder get _signOut => find.widgetWithText(OutlinedButton, 'Sign out');

Future<void> _openSettings(
  WidgetTester tester, {
  FakeAccountRepository? account,
  bool signedIn = true,
  Locale? locale,
}) => pumpApp(
  tester,
  initialLocation: AppRoutes.settings,
  account: account ?? FakeAccountRepository(),
  signedIn: signedIn,
  savedLocale: locale,
);

void main() {
  group('the account section, signed out', () {
    testWidgets('invites the customer to sign in or create an account and reads nothing from the server', (
      tester,
    ) async {
      final account = FakeAccountRepository();
      await _openSettings(tester, account: account, signedIn: false);

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Sign in to place orders and manage your details.'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Create account'), findsOneWidget);
      expect(find.text('Sign out'), findsNothing);
      expect(account.calls, isEmpty);
    });

    testWidgets('opens the sign-in and the sign-up pages', (tester) async {
      await _openSettings(tester, signedIn: false);

      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Email or phone number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Create account'));
      await tester.pumpAndSettle();
      expect(find.text('Full name'), findsOneWidget);
    });
  });

  group('the account section, signed in', () {
    testWidgets('shows the name and the email with its verified flag, and offers to add a phone', (tester) async {
      await _openSettings(tester);

      expect(find.text('Sara Demo'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text(ltr('sara@example.com')), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Phone'), findsNothing);
      expect(find.widgetWithText(OutlinedButton, 'Add a phone number'), findsOneWidget);
      expect(find.text('Confirm a phone number before you place your first order.'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Add an email address'), findsNothing);
    });

    testWidgets('shows a phone-only customer with an add-an-email button and no phone hint', (tester) async {
      await _openSettings(tester, account: FakeAccountRepository(onCurrentCustomer: () async => demoPhoneCustomer));

      expect(find.text('Omar Demo'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text(ltr('+971500000000')), findsOneWidget);
      expect(find.text('Email'), findsNothing);
      expect(find.widgetWithText(OutlinedButton, 'Add an email address'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Add a phone number'), findsNothing);
      expect(find.textContaining('first order'), findsNothing);
    });

    testWidgets('offers nothing to add when the account has both contacts', (tester) async {
      await _openSettings(tester, account: FakeAccountRepository(onCurrentCustomer: () async => demoCustomerWithPhone));

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Verified'), findsNWidgets(2));
      expect(find.textContaining('Add a'), findsNothing);
      expect(find.textContaining('Add an'), findsNothing);
    });

    testWidgets('says so, with a word and an icon, when a contact is not verified', (tester) async {
      const unverified = Customer(
        id: '3f2b8c1e-7a4d-4e6b-9c1a-5d2e8f0b1a13',
        fullName: 'Lina Demo',
        language: CustomerLanguage.english,
        email: 'lina@example.com',
        emailVerified: false,
        phone: '+971500000001',
        phoneVerified: true,
      );
      await _openSettings(tester, account: FakeAccountRepository(onCurrentCustomer: () async => unverified));

      expect(find.text('Not verified'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('shows progress while the profile is read, and then the profile', (tester) async {
      final answer = Completer<Customer>();
      await pumpApp(
        tester,
        initialLocation: AppRoutes.settings,
        account: FakeAccountRepository(onCurrentCustomer: () => answer.future),
        signedIn: true,
        settle: false,
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sara Demo'), findsNothing);

      answer.complete(demoCustomer);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Sara Demo'), findsOneWidget);
    });

    testWidgets('explains a failure and reads the profile again on "Try again"', (tester) async {
      var attempts = 0;
      final account = FakeAccountRepository(
        onCurrentCustomer: () async {
          attempts++;
          if (attempts == 1) {
            throw const NetworkFailure(NetworkFailureKind.offline);
          }
          return demoCustomer;
        },
      );
      await _openSettings(tester, account: account);

      expect(find.text('You are offline. Check your connection and try again.'), findsOneWidget);
      expect(find.text('Sara Demo'), findsNothing);
      expect(find.widgetWithText(OutlinedButton, 'Sign out'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Sara Demo'), findsOneWidget);
      expect(attempts, 2);
    });
  });

  group('signing out', () {
    testWidgets('revokes the token on the server first and then shows the signed-out section', (tester) async {
      final account = FakeAccountRepository();
      await _openSettings(tester, account: account);

      await tester.tap(_signOut);
      await tester.pumpAndSettle();

      expect(account.calls, containsAllInOrder(['currentCustomer', 'logOut']));
      expect(find.text('Sign in to place orders and manage your details.'), findsOneWidget);
      expect(find.text('Sara Demo'), findsNothing);
      expect(find.text('Sign out'), findsNothing);
    });

    testWidgets('signs out on this device even when the server could not be reached', (tester) async {
      final account = FakeAccountRepository(
        onLogOut: () async => throw const NetworkFailure(NetworkFailureKind.offline),
      );
      await _openSettings(tester, account: account);

      await tester.tap(_signOut);
      await tester.pumpAndSettle();

      expect(account.calls, contains('logOut'));
      expect(find.text('Sign in to place orders and manage your details.'), findsOneWidget);
      expect(find.text('Sara Demo'), findsNothing);
    });

    testWidgets('shows progress and cannot be tapped twice while the server answers', (tester) async {
      final answer = Completer<void>();
      final account = FakeAccountRepository(onLogOut: () => answer.future);
      await _openSettings(tester, account: account);

      await tester.tap(_signOut);
      await tester.pump();

      expect(tester.widget<OutlinedButton>(find.byType(OutlinedButton).last).onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      answer.complete();
      await tester.pumpAndSettle();

      expect(account.calls.where((call) => call == 'logOut'), hasLength(1));
      expect(find.text('Sign in to place orders and manage your details.'), findsOneWidget);
    });

    testWidgets('does not show the previous customer to the next one who signs in on the same page', (tester) async {
      final account = FakeAccountRepository();
      await _openSettings(tester, account: account);

      await tester.tap(_signOut);
      await tester.pumpAndSettle();
      expect(find.text('Sara Demo'), findsNothing);

      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'omar@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'a-demo-password');
      account.onCurrentCustomer = () async => demoPhoneCustomer;
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Omar Demo'), findsOneWidget);
      expect(find.text('Sara Demo'), findsNothing);
    });
  });

  group('the layout', () {
    testWidgets('reads right to left in Arabic and keeps the email and phone left to right', (tester) async {
      await _openSettings(
        tester,
        account: FakeAccountRepository(onCurrentCustomer: () async => demoCustomerWithPhone),
        locale: const Locale('ar'),
      );

      expect(find.text('الحساب'), findsOneWidget);
      expect(find.text('تم التحقق'), findsNWidgets(2));
      expect(find.text(ltr('sara@example.com')), findsOneWidget);
      expect(find.text(ltr('+971500000000')), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'تسجيل الخروج'), findsOneWidget);
      expect(Directionality.of(tester.element(find.text('الحساب'))), TextDirection.rtl);
    });

    for (final locale in [const Locale('en'), const Locale('ar')]) {
      testWidgets('survives the largest text scale on a small phone without overflow (${locale.languageCode})', (
        tester,
      ) async {
        tester.view
          ..physicalSize = const Size(360, 640)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await _openSettings(tester, account: FakeAccountRepository(), locale: locale);
        await tester.dragUntilVisible(_signOutFor(locale), find.byType(ListView), const Offset(0, -100));

        expect(tester.takeException(), isNull);
      });
    }
  });
}

Finder _signOutFor(Locale locale) =>
    find.widgetWithText(OutlinedButton, locale.languageCode == 'ar' ? 'تسجيل الخروج' : 'Sign out');
