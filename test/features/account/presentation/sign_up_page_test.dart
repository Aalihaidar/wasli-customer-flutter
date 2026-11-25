import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/core/error/api_issue.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/features/account/domain/account_contact.dart';
import 'package:wasli_customer/features/account/domain/customer_language.dart';
import 'package:wasli_customer/features/account/domain/sent_code.dart';

import '../../../support/fake_account_repository.dart';
import '../../../support/pump_app.dart';

Finder get _createButton => find.widgetWithText(FilledButton, 'Create account');

Future<void> _fill(
  WidgetTester tester, {
  String name = 'Sara Demo',
  String contact = 'sara@example.com',
  String password = 'a-demo-password',
}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), name);
  await tester.enterText(fields.at(1), contact);
  await tester.enterText(fields.at(2), password);
}

void main() {
  group('the sign-up page', () {
    testWidgets('is reached from the start page and asks for the name, the contact and the password', (tester) async {
      await pumpApp(tester);

      await tester.tap(_createButton);
      await tester.pumpAndSettle();

      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Email or phone number'), findsOneWidget);
      expect(find.text('We send a 6-digit code to confirm it.'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('asks for every empty field and sends nothing', (tester) async {
      final account = FakeAccountRepository();
      await pumpApp(tester, initialLocation: AppRoutes.signUp, account: account);

      await tester.tap(_createButton);
      await tester.pumpAndSettle();

      expect(find.text('This field is required.'), findsNWidgets(3));
      expect(account.calls, isEmpty);
    });

    testWidgets('hides the password until the customer shows it', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.signUp);
      EditableText password() => tester.widget<EditableText>(find.byType(EditableText).at(2));

      expect(password().obscureText, isTrue);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();

      expect(password().obscureText, isFalse);
      expect(find.byTooltip('Hide password'), findsOneWidget);
    });

    testWidgets('signs up with an email in the app language and opens the code page', (tester) async {
      final account = FakeAccountRepository();
      await pumpApp(tester, initialLocation: AppRoutes.signUp, account: account);

      await _fill(tester, contact: ' sara@example.com ');
      await tester.tap(_createButton);
      await tester.pumpAndSettle();

      expect(account.calls, ['signUp']);
      expect(account.lastContact, isA<EmailContact>());
      expect(account.lastContact!.value, 'sara@example.com');
      expect(account.lastLanguage, CustomerLanguage.english);
      expect(find.text('Enter the code'), findsOneWidget);
    });

    testWidgets('sends a phone number without its separators', (tester) async {
      final account = FakeAccountRepository();
      await pumpApp(tester, initialLocation: AppRoutes.signUp, account: account);

      await _fill(tester, contact: '+971 50 000 0000');
      await tester.tap(_createButton);
      await tester.pumpAndSettle();

      expect(account.lastContact, isA<PhoneContact>());
      expect(account.lastContact!.value, '+971500000000');
    });

    testWidgets('shows a spinner and blocks a second tap while the server answers', (tester) async {
      final completer = Completer<SentCode>();
      final account = FakeAccountRepository(onSignUp: (_, _) => completer.future);
      await pumpApp(tester, initialLocation: AppRoutes.signUp, account: account);

      await _fill(tester);
      await tester.tap(_createButton);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);

      completer.complete(demoSentCode);
      await tester.pumpAndSettle();
      expect(account.calls, ['signUp']);
    });

    testWidgets('says the contact is taken, in its own words', (tester) async {
      final account = FakeAccountRepository(
        onSignUp: (_, _) async => throw const ConflictFailure([ApiIssue(code: 'account_exists', attr: 'email')]),
      );
      await pumpApp(tester, initialLocation: AppRoutes.signUp, account: account);

      await _fill(tester);
      await tester.tap(_createButton);
      await tester.pumpAndSettle();

      expect(find.text('An account with this email or phone number already exists.'), findsOneWidget);
      expect(find.text('Create your account'), findsOneWidget);
    });

    testWidgets('says the password is not accepted for any password rule', (tester) async {
      final account = FakeAccountRepository(
        onSignUp: (_, _) async =>
            throw const ValidationFailure([ApiIssue(code: 'password_too_short', attr: 'password')]),
      );
      await pumpApp(tester, initialLocation: AppRoutes.signUp, account: account);

      await _fill(tester, password: 'x');
      await tester.tap(_createButton);
      await tester.pumpAndSettle();

      expect(find.text('This password is not accepted. Choose another one.'), findsOneWidget);
    });

    testWidgets('says it cannot reach the server when offline', (tester) async {
      final account = FakeAccountRepository(
        onSignUp: (_, _) async => throw const NetworkFailure(NetworkFailureKind.offline),
      );
      await pumpApp(tester, initialLocation: AppRoutes.signUp, account: account);

      await _fill(tester);
      await tester.tap(_createButton);
      await tester.pumpAndSettle();

      expect(find.text('Create your account'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('works in Arabic: right to left, the account language is Arabic', (tester) async {
      final account = FakeAccountRepository();
      await pumpApp(tester, initialLocation: AppRoutes.signUp, account: account, savedLocale: const Locale('ar'));

      expect(find.text('أنشئ حسابك'), findsOneWidget);
      expect(Directionality.of(tester.element(find.byType(Form))), TextDirection.rtl);

      await _fill(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'إنشاء حساب'));
      await tester.pumpAndSettle();

      expect(account.lastLanguage, CustomerLanguage.arabic);
      expect(find.text('أدخل الرمز'), findsOneWidget);
    });
  });
}
