import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/core/error/api_issue.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/features/account/domain/sent_code.dart';

import '../../../support/fake_account_repository.dart';
import '../../../support/pump_app.dart';

Finder get _confirm => find.widgetWithText(FilledButton, 'Confirm');

/// Opens the sign-up page, signs up and lands on the code page.
Future<void> _reachCodePage(
  WidgetTester tester,
  FakeAccountRepository account, {
  required DateTime Function() clock,
  Locale? locale,
}) async {
  await pumpApp(tester, initialLocation: AppRoutes.signUp, account: account, clock: clock, savedLocale: locale);
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'Sara Demo');
  await tester.enterText(fields.at(1), 'sara@example.com');
  await tester.enterText(fields.at(2), 'a-demo-password');
  await tester.tap(find.widgetWithText(FilledButton, locale == null ? 'Create account' : 'إنشاء حساب'));
  await tester.pumpAndSettle();
}

void main() {
  late FakeAccountRepository account;
  late DateTime now;

  setUp(() {
    account = FakeAccountRepository();
    now = DateTime.utc(2026, 11, 25, 10);
  });

  group('the code page', () {
    testWidgets('says where the code went, left to right, and keeps Confirm off until six digits are typed', (
      tester,
    ) async {
      await _reachCodePage(tester, account, clock: () => now);

      expect(find.text('We sent a 6-digit code to \u2066sara@example.com\u2069.'), findsOneWidget);
      expect(tester.widget<FilledButton>(_confirm).onPressed, isNull);

      await tester.enterText(find.byType(TextField), '12345');
      await tester.pump();
      expect(tester.widget<FilledButton>(_confirm).onPressed, isNull);

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();
      expect(tester.widget<FilledButton>(_confirm).onPressed, isNotNull);
    });

    testWidgets('keeps digits only, turns Arabic digits into Western ones and stops at six', (tester) async {
      await _reachCodePage(tester, account, clock: () => now);

      await tester.enterText(find.byType(TextField), '١٢٣ 456-789');
      await tester.pump();

      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '123456');
    });

    testWidgets('signs in with the right code and opens the start page', (tester) async {
      await _reachCodePage(tester, account, clock: () => now);

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();
      await tester.tap(_confirm);
      await tester.pumpAndSettle();

      expect(account.lastCode, '123456');
      expect(find.text('You are signed in.'), findsOneWidget);
      expect(find.text('Enter the code'), findsNothing);
    });

    testWidgets('says the code is wrong and stays on the page', (tester) async {
      account.onVerify = (_, _) async => throw const ValidationFailure([ApiIssue(code: 'code_invalid', attr: 'code')]);
      await _reachCodePage(tester, account, clock: () => now);

      await tester.enterText(find.byType(TextField), '000000');
      await tester.pump();
      await tester.tap(_confirm);
      await tester.pumpAndSettle();

      expect(find.text('That code is not correct. Check it and try again.'), findsOneWidget);
      expect(find.text('Enter the code'), findsOneWidget);
    });

    testWidgets('says too many wrong attempts and offers a new code', (tester) async {
      account.onVerify = (_, _) async => throw const ThrottledFailure(tooManyAttempts: true);
      await _reachCodePage(tester, account, clock: () => now);

      await tester.enterText(find.byType(TextField), '000000');
      await tester.pump();
      await tester.tap(_confirm);
      await tester.pumpAndSettle();

      expect(find.text('Too many wrong attempts. Send a new code.'), findsOneWidget);
    });

    testWidgets('counts down to the next code, enables the button, and a new code restarts the count', (tester) async {
      await _reachCodePage(tester, account, clock: () => now);
      Finder resend(String text) => find.widgetWithText(TextButton, text);

      expect(resend('Send a new code in \u20661:00\u2069'), findsOneWidget);
      expect(tester.widget<TextButton>(resend('Send a new code in \u20661:00\u2069')).onPressed, isNull);

      now = now.add(const Duration(seconds: 18));
      await tester.pump(const Duration(seconds: 1));
      expect(resend('Send a new code in \u20660:42\u2069'), findsOneWidget);

      now = now.add(const Duration(seconds: 42));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.widget<TextButton>(resend('Send a new code')).onPressed, isNotNull);

      await tester.tap(resend('Send a new code'));
      await tester.pumpAndSettle();

      expect(account.calls, ['signUp', 'resendCode']);
      expect(resend('Send a new code in \u20661:00\u2069'), findsOneWidget);
    });

    testWidgets('says the code has expired once its time is up', (tester) async {
      await _reachCodePage(tester, account, clock: () => now);
      expect(find.text('This code has expired. Send a new one.'), findsNothing);

      now = now.add(const Duration(minutes: 10));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('This code has expired. Send a new one.'), findsOneWidget);
    });

    testWidgets('clears the typed digits when a new code arrives', (tester) async {
      await _reachCodePage(tester, account, clock: () => now);
      await tester.enterText(find.byType(TextField), '123456');
      now = now.add(const Duration(minutes: 2));
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.widgetWithText(TextButton, 'Send a new code'));
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
    });

    testWidgets('a failed resend keeps the page and says why', (tester) async {
      account.onResend = (_) async => throw const NetworkFailure(NetworkFailureKind.offline);
      await _reachCodePage(tester, account, clock: () => now);
      now = now.add(const Duration(minutes: 2));
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.widgetWithText(TextButton, 'Send a new code'));
      await tester.pumpAndSettle();

      expect(find.text('Enter the code'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('blocks a second Confirm while the server answers', (tester) async {
      final completer = Completer<SentCode>();
      await _reachCodePage(tester, account, clock: () => now);
      account.onVerify = (_, _) => completer.future.then((_) => demoSession);

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();
      await tester.tap(_confirm);
      await tester.pump();

      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
      completer.complete(demoSentCode);
      await tester.pumpAndSettle();
    });

    testWidgets('without a code that was sent, the address sends the customer to sign up', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.verify, account: account);

      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Enter the code'), findsNothing);
    });

    testWidgets('works in Arabic, with the countdown and the address kept left to right', (tester) async {
      await _reachCodePage(tester, account, clock: () => now, locale: const Locale('ar'));

      expect(find.text('أرسلنا رمزًا من 6 أرقام إلى \u2066sara@example.com\u2069.'), findsOneWidget);
      expect(find.text('إرسال رمز جديد خلال \u20661:00\u2069'), findsOneWidget);
      expect(find.text('تأكيد'), findsOneWidget);
    });
  });
}
