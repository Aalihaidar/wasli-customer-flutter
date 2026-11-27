import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/not_found_page.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/features/settings/presentation/settings_page.dart';
import 'package:wasli_customer/features/start/presentation/start_page.dart';

import '../support/pump_app.dart';

void main() {
  group('the routes', () {
    test('have no trailing slash apart from the root', () {
      expect(AppRoutes.home, '/');
      expect(AppRoutes.settings, '/settings');
    });

    testWidgets('open the start page at /', (tester) async {
      await pumpApp(tester);

      expect(find.byType(StartPage), findsOneWidget);
    });

    testWidgets('open the settings page at /settings', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.settings);

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(StartPage), findsNothing);
    });

    testWidgets('show the page-not-found page for an address that matches nothing', (tester) async {
      await pumpApp(tester, initialLocation: '/no-such-page');

      expect(find.byType(NotFoundPage), findsOneWidget);
      expect(find.text('Page not found'), findsOneWidget);
      expect(find.text('Go to the start page'), findsOneWidget);
    });

    testWidgets('lead the page-not-found page back to the start page', (tester) async {
      await pumpApp(tester, initialLocation: '/no-such-page');

      await tester.tap(find.text('Go to the start page'));
      await tester.pumpAndSettle();

      expect(find.byType(StartPage), findsOneWidget);
      expect(find.byType(NotFoundPage), findsNothing);
    });

    testWidgets('show the page-not-found page in Arabic, right to left', (tester) async {
      await pumpApp(tester, initialLocation: '/no-such-page', savedLocale: const Locale('ar'));

      expect(find.text('الصفحة غير موجودة'), findsOneWidget);
      expect(Directionality.of(tester.element(find.byType(NotFoundPage))), TextDirection.rtl);
    });
  });
}
