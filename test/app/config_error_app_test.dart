import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/app/config_error_app.dart';
import 'package:wasli_customer/core/config/app_config_exception.dart';

void main() {
  const error = AppConfigException('API_BASE_URL is not set.');

  group('the configuration error page', () {
    testWidgets('explains the problem in English and names the wrong value', (tester) async {
      await tester.pumpWidget(const ConfigErrorApp(error: error));
      await tester.pumpAndSettle();

      expect(find.text('The app is not set up'), findsOneWidget);
      expect(find.text('This version of the app has a configuration problem. Please try again later.'), findsOneWidget);
      expect(find.text('API_BASE_URL is not set.'), findsOneWidget);
    });

    testWidgets('is in Arabic and right to left for a customer who chose Arabic', (tester) async {
      await tester.pumpWidget(const ConfigErrorApp(error: error, locale: Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.text('التطبيق غير مهيأ'), findsOneWidget);
      expect(Directionality.of(tester.element(find.text('التطبيق غير مهيأ'))), TextDirection.rtl);
      expect(find.text('API_BASE_URL is not set.'), findsOneWidget);
    });

    testWidgets('uses English for a language the app does not have', (tester) async {
      await tester.pumpWidget(const ConfigErrorApp(error: error, locale: Locale('fr')));
      await tester.pumpAndSettle();

      expect(find.text('The app is not set up'), findsOneWidget);
    });
  });
}
