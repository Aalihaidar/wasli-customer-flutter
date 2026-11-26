import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/core/error/api_issue.dart';
import 'package:wasli_customer/core/error/failure.dart';

import '../../../support/bidi.dart';
import '../../../support/fake_account_repository.dart';
import '../../../support/pump_app.dart';

Finder get _send => find.widgetWithText(FilledButton, 'Send code');
Finder get _change => find.widgetWithText(FilledButton, 'Change password');

/// Opens the page from the sign-in page, as a customer does.
Future<void> _open(
  WidgetTester tester,
  FakeAccountRepository account, {
  DateTime Function()? clock,
  Locale? locale,
}) async {
  await pumpApp(tester, initialLocation: AppRoutes.signIn, account: account, clock: clock, savedLocale: locale);
  await tester.tap(find.widgetWithText(TextButton, locale == null ? 'Forgot your password?' : 'نسيت كلمة المرور؟'));
  await tester.pumpAndSettle();
}

Future<void> _requestCode(WidgetTester tester, [String contact = 'sara@example.com']) async {
  await tester.enterText(find.byType(TextFormField), contact);
  await tester.tap(_send);
  await tester.pumpAndSettle();
}

/// Types the code and the new password and lets the button see them.
Future<void> _fillReset(WidgetTester tester, {String code = '123456', String password = 'a-new-demo-password'}) async {
  await tester.enterText(find.byType(TextField).first, code);
  await tester.enterText(find.byType(TextFormField).last, password);
  await tester.pump();
}

void main() {
  late FakeAccountRepository account;
  late DateTime now;

  setUp(() {
    account = FakeAccountRepository();
    now = DateTime.utc(2026, 11, 26, 10);
  });

  group('asking for the code', () {
    testWidgets('is reached from the sign-in page and asks for the email or phone number', (tester) async {
      await _open(tester, account);

      expect(find.text('Reset your password'), findsOneWidget);
      expect(find.text('Email or phone number'), findsOneWidget);
      expect(find.textContaining('If there is an account for it'), findsOneWidget);
    });

    testWidgets('asks for the field and sends nothing when it is empty', (tester) async {
      await _open(tester, account);

      await tester.tap(_send);
      await tester.pumpAndSettle();

      expect(find.text('This field is required.'), findsOneWidget);
      expect(account.calls, isEmpty);
    });

    testWidgets('tidies a phone number, asks for the code and moves on without saying whether the account exists', (
      tester,
    ) async {
      await _open(tester, account);

      await _requestCode(tester, '+971 50 000 0000');

      expect(account.lastResetIdentifier, '+971500000000');
      expect(find.textContaining('If there is an account for ${ltr('+971500000000')}'), findsOneWidget);
      expect(find.text('New password'), findsOneWidget);
      expect(find.text('6-digit code'), findsOneWidget);
    });

    testWidgets('asks to check the details when the server finds the contact invalid', (tester) async {
      account.onRequestPasswordReset = (_) async => throw const ValidationFailure([ApiIssue(code: 'invalid')]);
      await _open(tester, account);

      await _requestCode(tester, 'x');

      expect(find.text('Check the details and try again.'), findsOneWidget);
      expect(find.text('New password'), findsNothing);
    });

    testWidgets('asks to wait when the server throttles the request', (tester) async {
      account.onRequestPasswordReset = (_) async => throw const ThrottledFailure();
      await _open(tester, account);

      await _requestCode(tester);

      expect(find.text('Too many requests. Please wait a moment and try again.'), findsOneWidget);
    });

    testWidgets('cannot be sent twice while the server answers', (tester) async {
      final answer = Completer<Duration>();
      account.onRequestPasswordReset = (_) => answer.future;
      await _open(tester, account);

      await tester.enterText(find.byType(TextFormField), 'sara@example.com');
      await tester.tap(_send);
      await tester.pump();

      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
      answer.complete(const Duration(minutes: 10));
      await tester.pumpAndSettle();
      expect(account.calls.where((call) => call == 'requestPasswordReset'), hasLength(1));
    });
  });

  group('setting the new password', () {
    testWidgets('keeps the button off until six digits are typed, then sends the code and the password', (
      tester,
    ) async {
      await _open(tester, account);
      await _requestCode(tester);

      await tester.enterText(find.byType(TextField).first, '123');
      await tester.enterText(find.byType(TextFormField).last, 'a-new-demo-password');
      await tester.pump();
      expect(tester.widget<FilledButton>(_change).onPressed, isNull);

      await _fillReset(tester);
      await tester.tap(_change);
      await tester.pumpAndSettle();

      expect(account.lastResetIdentifier, 'sara@example.com');
      expect(account.lastResetCode, '123456');
      expect(account.lastNewPassword, 'a-new-demo-password');
    });

    testWidgets('asks for a new password and sends nothing when it is empty', (tester) async {
      await _open(tester, account);
      await _requestCode(tester);

      await _fillReset(tester, password: '');
      await tester.tap(_change);
      await tester.pumpAndSettle();

      expect(find.text('This field is required.'), findsOneWidget);
      expect(account.calls, isNot(contains('resetPassword')));
    });

    testWidgets('says the password was changed and leads to the sign-in page', (tester) async {
      await _open(tester, account);
      await _requestCode(tester);
      await _fillReset(tester);

      await tester.tap(_change);
      await tester.pumpAndSettle();

      expect(find.text('Your password was changed'), findsOneWidget);
      expect(find.text('You were signed out on every device. Sign in with your new password.'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Email or phone number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('says a password the rules refuse, and keeps what the customer typed', (tester) async {
      account.onResetPassword = (_, _, _) async =>
          throw const ValidationFailure([ApiIssue(code: 'password_too_short', attr: 'new_password')]);
      await _open(tester, account);
      await _requestCode(tester);
      await _fillReset(tester, password: 'short');

      await tester.tap(_change);
      await tester.pumpAndSettle();

      expect(find.text('This password is not accepted. Choose another one.'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField).first).controller!.text, '123456');
    });

    testWidgets('says a wrong code is wrong, an expired code is expired and too many attempts need a new code', (
      tester,
    ) async {
      await _open(tester, account);
      await _requestCode(tester);
      await _fillReset(tester);

      for (final (failure, text) in <(Failure, String)>[
        (
          const ValidationFailure([ApiIssue(code: 'code_invalid', attr: 'code')]),
          'That code is not correct. Check it and try again.',
        ),
        (
          const ValidationFailure([ApiIssue(code: 'code_expired', attr: 'code')]),
          'This code has expired. Send a new one.',
        ),
        (const ThrottledFailure(tooManyAttempts: true), 'Too many wrong attempts. Send a new code.'),
      ]) {
        account.onResetPassword = (_, _, _) async => throw failure;
        await tester.tap(_change);
        await tester.pumpAndSettle();
        expect(find.text(text), findsOneWidget, reason: text);
      }
    });

    testWidgets('says the code expired once its time is up', (tester) async {
      await _open(tester, account, clock: () => now);
      await _requestCode(tester);
      expect(find.text('This code has expired. Send a new one.'), findsNothing);

      now = now.add(const Duration(minutes: 10));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('This code has expired. Send a new one.'), findsOneWidget);
    });

    testWidgets('sends a new code to the same contact and empties the code field', (tester) async {
      await _open(tester, account, clock: () => now);
      await _requestCode(tester, '+971500000000');
      await _fillReset(tester);

      now = now.add(const Duration(minutes: 3));
      await tester.tap(find.widgetWithText(TextButton, 'Send a new code'));
      await tester.pumpAndSettle();

      expect(account.calls.where((call) => call == 'requestPasswordReset'), hasLength(2));
      expect(account.lastResetIdentifier, '+971500000000');
      expect(tester.widget<TextField>(find.byType(TextField).first).controller!.text, isEmpty);
    });
  });

  group('the address and the layout', () {
    testWidgets('opens from its address with a way back to the sign-in page', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.forgotPassword, account: account);

      expect(find.text('Reset your password'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('sends a signed-in customer to the start page', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.forgotPassword, account: account, signedIn: true);

      expect(find.text('Reset your password'), findsNothing);
      expect(find.text('You are signed in.'), findsOneWidget);
    });

    testWidgets('works right to left in Arabic and keeps the contact left to right', (tester) async {
      await _open(tester, account, locale: const Locale('ar'));

      expect(find.text('إعادة تعيين كلمة المرور'), findsOneWidget);
      expect(Directionality.of(tester.element(find.text('إعادة تعيين كلمة المرور'))), TextDirection.rtl);

      await tester.enterText(find.byType(TextFormField), 'sara@example.com');
      await tester.tap(find.widgetWithText(FilledButton, 'إرسال الرمز'));
      await tester.pumpAndSettle();

      expect(find.textContaining(ltr('sara@example.com')), findsOneWidget);
      expect(find.text('كلمة المرور الجديدة'), findsOneWidget);
    });

    for (final locale in [null, const Locale('ar')]) {
      testWidgets('survives the largest text scale on a small phone without overflow (${locale ?? 'en'})', (
        tester,
      ) async {
        tester.view
          ..physicalSize = const Size(360, 640)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await pumpApp(tester, initialLocation: AppRoutes.forgotPassword, account: account, savedLocale: locale);
        await tester.enterText(find.byType(TextFormField), 'sara@example.com');
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        await _fillReset(tester);

        expect(tester.takeException(), isNull);
      });
    }
  });
}
