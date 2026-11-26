import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/core/error/api_issue.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/features/account/domain/account_contact.dart';
import 'package:wasli_customer/features/account/domain/code_channel.dart';
import 'package:wasli_customer/features/account/domain/sent_code.dart';

import '../../../support/bidi.dart';
import '../../../support/fake_account_repository.dart';
import '../../../support/pump_app.dart';

const _phoneCode = SentCode(
  identifier: '+971500000000',
  channel: CodeChannel.sms,
  expiresIn: Duration(minutes: 10),
  resendAvailableIn: Duration(minutes: 1),
);

/// The disabled resend button while a minute is left: the time is isolated left to right.
final String _waitText = 'Send a new code in ${ltr('1:00')}';

Finder get _send => find.widgetWithText(FilledButton, 'Send code');
Finder get _confirm => find.widgetWithText(FilledButton, 'Confirm');

/// Opens the settings of a signed-in customer and taps the button that adds the missing phone number.
Future<void> _openAddPhone(WidgetTester tester, FakeAccountRepository account, {DateTime Function()? clock}) async {
  await pumpApp(tester, initialLocation: AppRoutes.settings, account: account, signedIn: true, clock: clock);
  await tester.tap(find.widgetWithText(OutlinedButton, 'Add a phone number'));
  await tester.pumpAndSettle();
}

/// Types the six digits and lets the Confirm button see them.
Future<void> _typeCode(WidgetTester tester, String code) async {
  await tester.enterText(find.byType(TextField), code);
  await tester.pump();
}

Future<void> _sendPhone(WidgetTester tester, [String phone = '+971 50 000 0000']) async {
  await tester.enterText(find.byType(TextFormField), phone);
  await tester.tap(_send);
  await tester.pumpAndSettle();
}

void main() {
  late FakeAccountRepository account;
  late DateTime now;

  setUp(() {
    account = FakeAccountRepository(onAddContact: (_) async => _phoneCode);
    now = DateTime.utc(2026, 11, 26, 10);
  });

  group('adding a phone number', () {
    testWidgets('is reached from the settings and asks for the number', (tester) async {
      await _openAddPhone(tester, account);

      expect(find.text('Add a phone number'), findsOneWidget);
      expect(find.text('Phone number'), findsOneWidget);
      expect(find.text('We send a 6-digit code to confirm it.'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('asks for the number and sends nothing when the field is empty', (tester) async {
      await _openAddPhone(tester, account);

      await tester.tap(_send);
      await tester.pumpAndSettle();

      expect(find.text('This field is required.'), findsOneWidget);
      expect(account.calls, isNot(contains('addContact')));
    });

    testWidgets('sends the tidied number as a phone, never as an email, and moves on to the code', (tester) async {
      await _openAddPhone(tester, account);

      await _sendPhone(tester, '+971 (50) 000-0000');

      expect(account.lastAddedContact, isA<PhoneContact>());
      expect(account.lastAddedContact!.value, '+971500000000');
      expect(find.text('We sent a 6-digit code to ${ltr('+971500000000')}.'), findsOneWidget);
      expect(find.text('6-digit code'), findsOneWidget);
    });

    testWidgets('saves the number when the code is right and shows it in the settings', (tester) async {
      account.onCurrentCustomer = () async =>
          account.calls.contains('verifyContact') ? demoCustomerWithPhone : demoCustomer;
      await _openAddPhone(tester, account);
      await _sendPhone(tester);

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();
      await tester.tap(_confirm);
      await tester.pumpAndSettle();

      expect(account.lastContactCode, '123456');
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text(ltr('+971500000000')), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Add a phone number'), findsNothing);
    });

    testWidgets('tells the customer a wrong code is wrong and lets them try again', (tester) async {
      account.onVerifyContact = (_) async => throw const ValidationFailure([ApiIssue(code: 'code_invalid')]);
      await _openAddPhone(tester, account);
      await _sendPhone(tester);

      await _typeCode(tester, '000000');
      await tester.tap(_confirm);
      await tester.pumpAndSettle();

      expect(find.text('That code is not correct. Check it and try again.'), findsOneWidget);
      expect(find.text('Add a phone number'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '000000');
    });

    testWidgets('asks for a new code when the server no longer holds the pending contact', (tester) async {
      account.onVerifyContact = (_) async => throw const ConflictFailure([ApiIssue(code: 'no_pending_contact')]);
      await _openAddPhone(tester, account);
      await _sendPhone(tester);

      await _typeCode(tester, '123456');
      await tester.tap(_confirm);
      await tester.pumpAndSettle();

      expect(find.text('This code has expired. Send a new one.'), findsOneWidget);
    });

    testWidgets('sends a new code to the same number once the wait is over, and empties the field', (tester) async {
      await _openAddPhone(tester, account, clock: () => now);
      await _sendPhone(tester);
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();

      expect(find.text(_waitText), findsOneWidget);
      expect(tester.widget<TextButton>(find.widgetWithText(TextButton, _waitText)).onPressed, isNull);

      now = now.add(const Duration(minutes: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.widgetWithText(TextButton, 'Send a new code'));
      await tester.pumpAndSettle();

      expect(account.calls.where((call) => call == 'addContact'), hasLength(2));
      expect(account.lastAddedContact!.value, '+971500000000');
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
    });

    testWidgets('says the number belongs to another account', (tester) async {
      account.onAddContact = (_) async => throw const ConflictFailure([ApiIssue(code: 'account_exists')]);
      await _openAddPhone(tester, account);

      await _sendPhone(tester);

      expect(find.text('This email address or phone number is already used by another account.'), findsOneWidget);
      expect(find.text('6-digit code'), findsNothing);
    });

    testWidgets('says the kind of contact is already on the account', (tester) async {
      account.onAddContact = (_) async => throw const ConflictFailure([ApiIssue(code: 'contact_already_set')]);
      await _openAddPhone(tester, account);

      await _sendPhone(tester);

      expect(find.text('This kind of contact is already on your account.'), findsOneWidget);
    });

    testWidgets('asks to check the details when the server finds the number invalid, and to wait when throttled', (
      tester,
    ) async {
      account.onAddContact = (_) async => throw const ValidationFailure([ApiIssue(code: 'invalid', attr: 'phone')]);
      await _openAddPhone(tester, account);

      await _sendPhone(tester, '12');
      expect(find.text('Check the details and try again.'), findsOneWidget);

      account.onAddContact = (_) async => throw const ThrottledFailure();
      await tester.tap(_send);
      await tester.pumpAndSettle();
      expect(find.text('Too many requests. Please wait a moment and try again.'), findsOneWidget);
    });

    testWidgets('cannot be sent twice while the server answers', (tester) async {
      final answer = Completer<SentCode>();
      account.onAddContact = (_) => answer.future;
      await _openAddPhone(tester, account);

      await tester.enterText(find.byType(TextFormField), '+971500000000');
      await tester.tap(_send);
      await tester.pump();

      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      answer.complete(_phoneCode);
      await tester.pumpAndSettle();
      expect(account.calls.where((call) => call == 'addContact'), hasLength(1));
    });

    testWidgets('goes back to the settings from the back button without saving anything', (tester) async {
      await _openAddPhone(tester, account);
      await _sendPhone(tester);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(account.calls, isNot(contains('verifyContact')));
    });
  });

  group('adding an email address', () {
    testWidgets('sends the address as an email, asks for it with its own labels and returns to the settings', (
      tester,
    ) async {
      account = FakeAccountRepository(
        onCurrentCustomer: () async => demoPhoneCustomer,
        onVerifyContact: (_) async => demoCustomerWithPhone,
      );
      await pumpApp(tester, initialLocation: AppRoutes.settings, account: account, signedIn: true);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Add an email address'));
      await tester.pumpAndSettle();

      expect(find.text('Email address'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), ' sara@example.com ');
      await tester.tap(_send);
      await tester.pumpAndSettle();

      expect(account.lastAddedContact, isA<EmailContact>());
      expect(account.lastAddedContact!.value, 'sara@example.com');

      await _typeCode(tester, '654321');
      await tester.tap(_confirm);
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('the address and the layout', () {
    testWidgets('sends a signed-out visitor to the sign-in page', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.addPhone, account: account);

      expect(find.text('Sign in'), findsWidgets);
      expect(find.text('Phone number'), findsNothing);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('opens from its address for a signed-in customer, with a way back to the settings', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.addEmail, account: account, signedIn: true);

      expect(find.text('Email address'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('reads right to left in Arabic and keeps the number left to right', (tester) async {
      await pumpApp(
        tester,
        initialLocation: AppRoutes.addPhone,
        account: account,
        signedIn: true,
        savedLocale: const Locale('ar'),
      );

      expect(find.text('إضافة رقم هاتف'), findsOneWidget);
      expect(find.text('رقم الهاتف'), findsOneWidget);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.textDirection, TextDirection.ltr);
      expect(Directionality.of(tester.element(find.text('رقم الهاتف'))), TextDirection.rtl);
    });

    for (final route in [AppRoutes.addEmail, AppRoutes.addPhone]) {
      testWidgets('survives the largest text scale on a small phone without overflow ($route)', (tester) async {
        tester.view
          ..physicalSize = const Size(360, 640)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await pumpApp(tester, initialLocation: route, account: account, signedIn: true);
        await tester.enterText(find.byType(TextFormField), '+971500000000');
        await tester.tap(_send);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
