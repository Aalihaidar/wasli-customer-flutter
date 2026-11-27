import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/features/account/presentation/sign_in_page.dart';
import 'package:wasli_customer/features/account/presentation/sign_up_page.dart';
import 'package:wasli_customer/features/settings/presentation/settings_page.dart';
import 'package:wasli_customer/features/start/presentation/restaurant_page.dart';
import 'package:wasli_customer/features/start/presentation/start_page.dart';

import '../support/fake_account_repository.dart';
import '../support/pump_app.dart';

void main() {
  group('where the sign-in pages lead after signing in', () {
    testWidgets('a signed-in customer who opens a sign-in link with a restaurant goes to that restaurant', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: '/signin?next=%2Fr%2Fdemo-cafe', signedIn: true);

      expect(find.byType(RestaurantPage), findsOneWidget);
    });

    testWidgets('anything but a restaurant page is ignored, so a crafted link cannot send the customer elsewhere', (
      tester,
    ) async {
      for (final next in [
        'https://evil.example',
        '//evil.example',
        '/settings',
        '/r/-bad',
        '/r/nearby',
        '/r/demo-cafe/extra',
        '/r/',
        'r/demo-cafe',
        '',
      ]) {
        await pumpApp(tester, initialLocation: '/signin?next=${Uri.encodeQueryComponent(next)}', signedIn: true);

        expect(find.byType(StartPage), findsOneWidget, reason: 'next=$next');
        expect(find.byType(SettingsPage), findsNothing, reason: 'next=$next');
        expect(find.byType(RestaurantPage), findsNothing, reason: 'next=$next');
      }
    });

    testWidgets('with no next, signing in leads to the start page as before', (tester) async {
      await pumpApp(tester, initialLocation: '/signin', account: FakeAccountRepository());

      await tester.enterText(find.byType(TextFormField).at(0), 'sara@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'a-demo-password');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.byType(StartPage), findsOneWidget);
    });

    testWidgets('creating an account first and then choosing sign-in still leads back to the restaurant', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: '/r/demo-cafe', account: FakeAccountRepository());

      await tester.tap(find.widgetWithText(TextButton, 'Create account'));
      await tester.pumpAndSettle();
      expect(find.byType(SignUpPage), findsOneWidget);

      await tester.tap(find.text('Already have an account? Sign in'));
      await tester.pumpAndSettle();
      expect(find.byType(SignInPage), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'sara@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'a-demo-password');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.byType(RestaurantPage), findsOneWidget);
      expect(find.text('Welcome to Demo Cafe.'), findsOneWidget);
    });
  });
}
