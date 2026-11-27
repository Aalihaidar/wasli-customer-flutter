import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/app.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/core/error/api_issue.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/network/network_providers.dart';
import 'package:wasli_customer/core/session/session_controller.dart';
import 'package:wasli_customer/features/account/domain/customer_session.dart';
import 'package:wasli_customer/features/start/presentation/start_page.dart';

import '../../../support/fake_account_repository.dart';
import '../../../support/pump_app.dart';

Finder get _signInButton => find.widgetWithText(FilledButton, 'Sign in');

Future<void> _fill(
  WidgetTester tester, {
  String identifier = 'sara@example.com',
  String password = 'a-demo-password',
}) async {
  await tester.enterText(find.byType(TextFormField).at(0), identifier);
  await tester.enterText(find.byType(TextFormField).at(1), password);
}

void main() {
  group('the sign-in page', () {
    testWidgets('is reached from the start page', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byTooltip('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Email or phone number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('asks for both fields and sends nothing when they are empty', (tester) async {
      final account = FakeAccountRepository();
      await pumpApp(tester, initialLocation: AppRoutes.signIn, account: account);

      await tester.tap(_signInButton);
      await tester.pumpAndSettle();

      expect(find.text('This field is required.'), findsNWidgets(2));
      expect(account.calls, isEmpty);
    });

    testWidgets('signs in, tidies a phone number, and opens the start page signed in', (tester) async {
      final account = FakeAccountRepository();
      await pumpApp(tester, initialLocation: AppRoutes.signIn, account: account);

      await _fill(tester, identifier: '+971 50 000 0000');
      await tester.tap(_signInButton);
      await tester.pumpAndSettle();

      expect(account.lastIdentifier, '+971500000000');
      expect(find.byType(StartPage), findsOneWidget);
    });

    testWidgets('a refused sign-in says one thing whatever was wrong, for a 401 and a 400 alike', (tester) async {
      for (final failure in <Failure>[
        const UnauthenticatedFailure(),
        const ValidationFailure([ApiIssue(code: 'invalid_credentials')]),
      ]) {
        final account = FakeAccountRepository(onLogIn: (_, _) async => throw failure);
        await pumpApp(tester, initialLocation: AppRoutes.signIn, account: account);

        await _fill(tester);
        await tester.tap(_signInButton);
        await tester.pumpAndSettle();

        expect(find.text('The email, phone number or password is not correct.'), findsOneWidget, reason: '$failure');
        expect(find.byType(StartPage), findsNothing);
      }
    });

    testWidgets('a blocked account is told so', (tester) async {
      final account = FakeAccountRepository(onLogIn: (_, _) async => throw const PermissionDeniedFailure());
      await pumpApp(tester, initialLocation: AppRoutes.signIn, account: account);

      await _fill(tester);
      await tester.tap(_signInButton);
      await tester.pumpAndSettle();

      expect(find.text('This account cannot be used to sign in.'), findsOneWidget);
    });

    testWidgets('an account that was never confirmed gets a new code and the code page', (tester) async {
      final account = FakeAccountRepository(onLogIn: (_, _) async => throw const AccountNotVerifiedFailure());
      await pumpApp(tester, initialLocation: AppRoutes.signIn, account: account);

      await _fill(tester);
      await tester.tap(_signInButton);
      await tester.pumpAndSettle();

      expect(account.calls, ['logIn', 'resendCode']);
      expect(find.text('Enter the code'), findsOneWidget);
      expect(find.text('We sent a 6-digit code to \u2066sara@example.com\u2069.'), findsOneWidget);
    });

    testWidgets('too many tries uses the throttled text', (tester) async {
      final account = FakeAccountRepository(onLogIn: (_, _) async => throw const ThrottledFailure());
      await pumpApp(tester, initialLocation: AppRoutes.signIn, account: account);

      await _fill(tester);
      await tester.tap(_signInButton);
      await tester.pumpAndSettle();

      expect(find.text('Too many requests. Please wait a moment and try again.'), findsOneWidget);
    });

    testWidgets('blocks a second tap while the server answers', (tester) async {
      final completer = Completer<CustomerSession>();
      final account = FakeAccountRepository(onLogIn: (_, _) => completer.future);
      await pumpApp(tester, initialLocation: AppRoutes.signIn, account: account);

      await _fill(tester);
      await tester.tap(_signInButton);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
      completer.complete(demoSession);
      await tester.pumpAndSettle();
    });

    testWidgets('links to sign-up and back', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.signIn);

      await tester.tap(find.text('New here? Create an account'));
      await tester.pumpAndSettle();
      expect(find.text('Create your account'), findsOneWidget);

      await tester.tap(find.text('Already have an account? Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Email or phone number'), findsOneWidget);
      expect(find.text('Create your account'), findsNothing);
    });

    testWidgets('works in Arabic', (tester) async {
      final account = FakeAccountRepository();
      await pumpApp(tester, initialLocation: AppRoutes.signIn, account: account, savedLocale: const Locale('ar'));

      expect(find.text('تسجيل الدخول'), findsWidgets);
      expect(Directionality.of(tester.element(find.byType(Form))), TextDirection.rtl);

      await _fill(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'تسجيل الدخول'));
      await tester.pumpAndSettle();

      expect(find.byType(StartPage), findsOneWidget);
    });
  });

  group('the router and the session', () {
    ProviderContainer containerOf(WidgetTester tester) => ProviderScope.containerOf(tester.element(find.byType(App)));

    testWidgets('a signed-in customer is sent away from the sign-in and sign-up pages', (tester) async {
      await pumpApp(tester);
      await containerOf(tester).read(sessionProvider.notifier).signIn('demo-token-not-a-real-token');
      await tester.pumpAndSettle();

      for (final path in [AppRoutes.signIn, AppRoutes.signUp]) {
        GoRouter.of(tester.element(find.byType(Scaffold).first)).go(path);
        await tester.pumpAndSettle();

        expect(find.byType(StartPage), findsOneWidget, reason: path);
      }
    });

    testWidgets('a 401 that ends the session opens the sign-in page', (tester) async {
      await pumpApp(tester);
      final container = containerOf(tester);
      await container.read(sessionProvider.notifier).signIn('demo-token-not-a-real-token');
      await tester.pumpAndSettle();
      expect(find.byType(StartPage), findsOneWidget);

      container.read(sessionExpiredProvider.notifier).announce();
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email or phone number'), findsOneWidget);
    });
  });
}
